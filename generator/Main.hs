{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad ((<=<))
import Hakyll
import System.FilePath.Posix (dropFileName, splitDirectories)
import Text.Link.Pandoc (addAnchorLinkToHeadings, processEmbedLinks)
import Text.Pandoc.Options (WriterOptions (..))

main :: IO ()
main = hakyll do
  match "asset/**" do
    route . gsubRoute "asset/" $ const ""
    compile copyFileCompiler

  create ["post/index.html"] do
    route idRoute
    compile $
      makeItem ""
        >>= loadAndApplyTemplate "template/post-index.html" (indexTitleContext <> postsContext <> defaultContext)
        >>= loadAndApplyTemplate "template/default.html" (indexTitleContext <> fragmentsContext <> defaultContext)
        >>= relativizeUrls

  match "content/post/*.md" do
    route $ gsubRoute "content/" (const "") `composeRoutes` setExtension "html"
    compile $
      markdownCompiler
        >>= loadAndApplyTemplate "template/post.html" defaultContext
        >>= loadAndApplyTemplate "template/default.html" (fragmentsContext <> defaultContext)
        >>= relativizeUrls

  match "template/*" do
    compile templateBodyCompiler

markdownCompiler :: Compiler (Item String)
markdownCompiler =
  pandocCompilerWithTransform
    defaultHakyllReaderOptions
    writerOptions
    (addAnchorLinkToHeadings . processEmbedLinks)
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
    pat = "content/post/*" <> complement "**/index.html"

indexTitleContext :: Context String
indexTitleContext = field "title" f
  where
    f = fmap (("Index of " <>) . dropFileName) . getJustRoute . itemIdentifier

getJustRoute :: Identifier -> Compiler FilePath
getJustRoute ident =
  getRoute ident >>= \case
    Nothing -> noResult "getJustRoute: non-routed item"
    Just path -> pure path
