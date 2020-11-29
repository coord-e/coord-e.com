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
import Text.Link.Pandoc (addAnchorLinkToHeadings, processEmbedLinks)
import Text.Pandoc (Pandoc)
import Text.Pandoc.Options (WriterOptions (..))

main :: IO ()
main = do
  renderFormulae <- initFormulaCompilerSVG 1000 latexEnvOptions
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
          >>= loadAndApplyTemplate "template/default.html" (fragmentsContext <> defaultContext)
          >>= relativizeUrls

    create ["post/index.html"] do
      route idRoute
      compile $
        makeItem ""
          >>= loadAndApplyTemplate "template/post-index.html" (indexTitleContext <> postsContext <> defaultContext)
          >>= loadAndApplyTemplate "template/default.html" (indexTitleContext <> fragmentsContext <> defaultContext)
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

indexTitleContext :: Context String
indexTitleContext = field "title" f
  where
    f = fmap (("Index of " <>) . dropFileName) . getJustRoute . itemIdentifier

getJustRoute :: Identifier -> Compiler FilePath
getJustRoute ident =
  getRoute ident >>= \case
    Nothing -> noResult "getJustRoute: non-routed item"
    Just path -> pure path
