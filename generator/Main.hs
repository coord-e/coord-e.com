{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns #-}

module Main where

import Control.Monad ((<=<))
import Hakyll
import Hakyll.Contrib.LaTeX (initFormulaCompilerSVG)
import Image.LaTeX.Render (EnvironmentOptions (..), defaultEnv)
import Image.LaTeX.Render.Pandoc (PandocFormulaOptions (..), defaultPandocFormulaOptions)
import System.FilePath.Posix
  ( dropFileName,
    splitDirectories,
    takeBaseName,
    takeDirectory,
    takeExtension,
    (<.>),
    (</>),
  )
import System.Process.Typed (proc, readProcess_)
import Text.Formula.Pandoc (renderFormulae)
import Text.Link.Pandoc (addAnchorLinkToHeadings, processEmbedLinks)
import Text.Pandoc (Pandoc)
import Text.Pandoc.Options (WriterOptions (..))
import Text.Pandoc.UTF8 (toStringLazy)

main :: IO ()
main = do
  renderFormulae <- initFormulaCompilerSVG 1000 latexEnvOptions
  gitCommit <- getCurrentCommit
  hakyll do
    match "asset/**" do
      route . gsubRoute "asset/" $ const ""
      compile copyFileCompiler

    match ("content/post/*/*" .&&. imageFile) do
      route $ gsubRoute "content/" (const "")
      compile copyFileCompiler

    match ("content/post/*.md" .||. "content/post/*/index.md") do
      route $
        unIndexRoute
          `composeRoutes` gsubRoute "content/" (const "")
          `composeRoutes` setExtension "html"
      compile $
        markdownCompiler renderFormulae
          >>= subDirUrls
          >>= loadAndApplyTemplate "template/post.html" defaultContext
          >>= loadAndApplyTemplate "template/default.html" (gitRefContext gitCommit <> fragmentsContext <> defaultContext)
          >>= relativizeUrls

    create ["post/index.html"] do
      route idRoute
      compile $
        makeItem ""
          >>= loadAndApplyTemplate "template/post-index.html" (indexTitleContext True <> postsContext <> defaultContext)
          >>= loadAndApplyTemplate "template/default.html" (indexTitleContext False <> fragmentsContext <> bodyField "body")
          >>= relativizeUrls

    match "template/*" do
      compile templateBodyCompiler

imageFile :: Pattern
imageFile = fromRegex "\\.(png|jpg|svg)$"

unIndexRoute :: Routes
unIndexRoute = customRoute f
  where
    f (toFilePath -> p)
      | takeBaseName p == "index" = takeDirectory p <.> takeExtension p
      | otherwise = p

latexEnvOptions :: EnvironmentOptions
latexEnvOptions =
  defaultEnv
    { latexFontSize = 14
    }

subDirUrls :: Item String -> Compiler (Item String)
subDirUrls item = do
  path <- getJustRoute $ itemIdentifier item
  pure $ fmap (withUrls $ f path) item
  where
    f p ('.' : '/' : url) = '.' : '/' : takeBaseName p </> url
    f _ url = url

markdownCompiler ::
  (PandocFormulaOptions -> Pandoc -> Compiler Pandoc) ->
  Compiler (Item String)
markdownCompiler renderFormulae =
  pandocCompilerWithTransformM
    defaultHakyllReaderOptions
    writerOptions
    (renderFormulae defaultPandocFormulaOptions . addAnchorLinkToHeadings . processEmbedLinks)
  where
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
postsContext = listField "posts" defaultContext (recentFirst =<< loadAll pat)
  where
    pat = "content/post/*.md" .||. "content/post/*/index.md"

indexTitleContext :: Bool -> Context String
indexTitleContext isHtml = field "title" f
  where
    f = fmap (makeTitle . dropFileName) . getJustRoute . itemIdentifier
    makeTitle path
      | isHtml = "Index of <code>" <> path <> "</code>"
      | otherwise = "Index of " <> path

gitRefContext :: String -> Context String
gitRefContext = constField "gitref"

getCurrentCommit :: IO String
getCurrentCommit = do
  (out, _) <- readProcess_ p
  pure $ toStringLazy out
  where
    p = proc "git" ["rev-parse", "HEAD"]

getJustRoute :: Identifier -> Compiler FilePath
getJustRoute ident =
  getRoute ident >>= \case
    Nothing -> noResult "getJustRoute: non-routed item"
    Just path -> pure path
