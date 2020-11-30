{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ViewPatterns #-}

module Text.Formula.Pandoc (renderFormulae) where

import Data.Maybe (mapMaybe)
import Data.Text (Text, pack, stripPrefix, stripSuffix, unpack)
import Hakyll.Contrib.LaTeX (compileFormulaeSVG)
import Hakyll.Core.Compiler (Compiler)
import Image.LaTeX.Render (defaultEnv)
import Image.LaTeX.Render.Pandoc (defaultPandocFormulaOptions)
import Text.HTML.TagSoup (Tag (..), parseTags, renderTags)
import Text.Pandoc (Inline (..), Pandoc)
import Text.Pandoc.Walk (walk)
import Text.Read (readMaybe)

renderFormulae :: Pandoc -> Compiler Pandoc
renderFormulae = fmap resizeMath . compileFormulaeSVG defaultEnv defaultPandocFormulaOptions . walk wrapMath
  where
    wrapMath i@(Math _ _) = Span ("", ["math"], []) [i]
    wrapMath i = i

pattern FloatPt :: Double -> Text
pattern FloatPt t <- (stripSuffix "pt" -> Just (readMaybe . unpack -> Just t))

resizeMath :: Pandoc -> Pandoc
resizeMath = walk f
  where
    f (Span a@(_, ["math"], _) [RawInline "html" svg]) =
      Span a [RawInline "html" (renderTags (map processTag (parseTags svg)))]
    f i = i
    processTag (TagOpen s attrs) = TagOpen s (mapMaybe processAttr attrs)
    processTag t = t
    processAttr ("height", FloatPt value) = Just ("height", convertLength value <> "em")
    processAttr ("style", stripPrefix "vertical-align: " -> Just (FloatPt value)) =
      Just ("style", "vertical-align: " <> convertLength value <> "em")
    processAttr ("width", _) = Nothing
    processAttr a = Just a
    convertLength = pack . show . (/ factor)
    factor = 11.5
