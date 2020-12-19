{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns #-}

module Main where

import Control.Monad ((<=<))
import Hakyll
import System.Environment (lookupEnv)
import System.FilePath.Posix
  ( dropFileName,
    splitDirectories,
    takeBaseName,
    takeDirectory,
    takeExtension,
    takeFileName,
    (<.>),
    (</>),
  )
import System.Process.Typed (proc, readProcess_)
import Text.Formula.Pandoc (renderFormulae)
import Text.Link.Pandoc (addAnchorLinkToHeadings, processEmbedLinks)
import Text.Pandoc.Extensions (Extension (..), enableExtension, pandocExtensions)
import Text.Pandoc.Options (ReaderOptions (..), WriterOptions (..))
import Text.Pandoc.UTF8 (toStringLazy)
import Text.TableOfContents.Pandoc (addToC)

main :: IO ()
main = do
  gitCommitContext <- getGitCommitContext
  hakyll do
    match "asset/**" do
      route . gsubRoute "asset/" $ const ""
      compile copyFileCompiler

    match ("post/*/*" .&&. imageFile) do
      route idRoute
      compile copyFileCompiler

    match "post/*/*.gv" do
      route $ setExtension "svg"
      compile $
        getResourceLBS
          >>= withItemBody (unixFilterLBS "dot" ["-Tsvg"])

    match ("post/*.md" .||. "post/*/index.md") do
      route $
        unIndexRoute `composeRoutes` setExtension "html"
      compile $
        markdownCompiler
          >>= subDirUrls
          >>= saveSnapshot "content"
          >>= loadAndApplyTemplate "template/post.html" defaultContext
          >>= loadAndApplyTemplate "template/default.html" (gitCommitContext <> fragmentsContext <> defaultContext)
          >>= relativizeUrls

    create ["post/index.html"] do
      route idRoute
      compile $
        makeItem ""
          >>= loadAndApplyTemplate "template/post-index.html" (indexContext <> postsContext <> defaultContext)
          >>= loadAndApplyTemplate "template/default.html" (indexContext <> fragmentsContext <> bodyField "body")
          >>= relativizeUrls

    create ["post/rss.xml"] do
      route idRoute
      compile $
        loadAllSnapshots allPosts "content"
          >>= fmap (take 10) . recentFirst
          >>= renderRss feedConfig (bodyField "description" <> defaultContext)

    match "template/*" do
      compile templateBodyCompiler

feedConfig :: FeedConfiguration
feedConfig =
  FeedConfiguration
    { feedTitle = "coord-e.com/post",
      feedDescription = "Posts in coord-e.com",
      feedAuthorName = "coord_e",
      feedAuthorEmail = "me@coord-e.com",
      feedRoot = "https://coord-e.com"
    }

imageFile :: Pattern
imageFile = fromRegex "\\.(png|jpg|svg)$"

unIndexRoute :: Routes
unIndexRoute = customRoute f
  where
    f (toFilePath -> p)
      | takeBaseName p == "index" = takeDirectory p <.> takeExtension p
      | otherwise = p

subDirUrls :: Item String -> Compiler (Item String)
subDirUrls item = do
  path <- getJustRoute $ itemIdentifier item
  pure $ fmap (withUrls $ f path) item
  where
    f p ('.' : '/' : url) = '.' : '/' : takeBaseName p </> url
    f _ url = url

markdownCompiler :: Compiler (Item String)
markdownCompiler =
  pandocCompilerWithTransformM
    readerOptions
    writerOptions
    (renderFormulae . addAnchorLinkToHeadings . addToC . processEmbedLinks)
  where
    readerOptions =
      defaultHakyllReaderOptions
        { readerExtensions = enableExtension Ext_emoji pandocExtensions
        }
    writerOptions =
      defaultHakyllWriterOptions
        { writerNoteTitles = True,
          writerSectionDivs = True
        }

fragmentsContext :: Context String
fragmentsContext = listFieldWith "fragments" fields items
  where
    fields =
      field "fragment" (pure . fst . itemBody)
        <> field "path" (pure . snd . itemBody)
    items = traverse makeItem . makePathPairs . splitDirectories <=< getJustRoute . itemIdentifier
    makePathPairs fragments = foldr go (const []) fragments ""
    go fragment k = \path ->
      let path' = path ++ '/' : fragment in (fragment, path') : k path'

postsContext :: Context String
postsContext = listField "posts" defaultContext (recentFirst =<< loadAll allPosts)

allPosts :: Pattern
allPosts = "post/*.md" .||. "post/*/index.md"

indexContext :: Context String
indexContext = field "title" f <> field "index" getIndexPath
  where
    f = fmap ("Index of " <>) . getIndexPath
    getIndexPath = fmap (('/' :) . removeIndex) . getJustRoute . itemIdentifier
    removeIndex path
      | takeFileName path == "index.html" = dropFileName path
      | otherwise = path

getGitCommitContext :: IO (Context String)
getGitCommitContext = constField "commit" <$> getCurrentCommit

getCurrentCommit :: IO String
getCurrentCommit = maybe fromGitCommand pure =<< lookupEnv "GENERATOR_COMMIT_ID"
  where
    fromGitCommand = do
      (out, _) <- readProcess_ $ proc "git" ["rev-parse", "HEAD"]
      pure $ toStringLazy out

getJustRoute :: Identifier -> Compiler FilePath
getJustRoute ident =
  getRoute ident >>= \case
    Nothing -> noResult "getJustRoute: non-routed item"
    Just path -> pure path
