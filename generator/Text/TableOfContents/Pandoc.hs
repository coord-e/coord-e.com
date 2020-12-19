{-# LANGUAGE OverloadedStrings #-}

module Text.TableOfContents.Pandoc
  ( addToC,
  )
where

import Control.Monad ((<=<))
import Data.Foldable (foldl')
import Data.Text (Text)
import Data.Tree (Tree (..))
import Text.Pandoc.Definition (Block (..), Inline (..), Pandoc, nullAttr)
import Text.Pandoc.Walk (query, walk)

addToC :: Pandoc -> Pandoc
addToC doc = walk f doc
  where
    f (Para [Str "[:contents]"]) = toc
    f b = b
    toc = generateToC doc

data Header
  = HeaderContent Text [Inline]
  | HeaderNone

generateToC :: Pandoc -> Block
generateToC = toToC . query f
  where
    f (Header level (targetId, _, _) contents) = [(level, HeaderContent targetId contents)]
    f _ = []
    toToC = toToCDiv . BulletList . toBulletLists . (shiftLevels <=< foldl' g [])
    g acc (level, hd) = appendAt level hd acc
    appendAt 0 hd blocks = Node hd [] : blocks
    appendAt level hd (Node x xs : t) = Node x (appendAt (level - 1) hd xs) : t
    appendAt level hd [] = [Node HeaderNone (appendAt (level - 1) hd [])]
    shiftLevels (Node HeaderNone xs) = shiftLevels =<< xs
    shiftLevels (Node hd xs) = [Node hd (shiftLevels =<< xs)]
    toBulletLists = reverse . map toBulletList
    toBulletList (Node hd []) = [toHeaderLink hd]
    toBulletList (Node hd children) = [toHeaderLink hd, BulletList (toBulletLists children)]
    toHeaderLink (HeaderContent targetId contents) = Plain [Link nullAttr contents (makeTarget targetId)]
    toHeaderLink HeaderNone = Plain []
    makeTarget i = ("#" <> i, "")
    toToCDiv b = Div tocAttr [b]
    tocAttr = ("", ["toc"], [])
