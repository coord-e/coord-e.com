{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Text.Link.Pandoc
  ( addAnchorLinkToHeadings,
    processEmbedLinks,
  )
where

import qualified Data.Text as Text (null)
import NeatInterpolation
import Text.Pandoc.Definition (Block (..), Inline (..), Pandoc, nullAttr)
import Text.Pandoc.Walk (walk)

addAnchorLinkToHeadings :: Pandoc -> Pandoc
addAnchorLinkToHeadings = walk f
  where
    f (Header level attr@(targetId, _, _) content) = Header level attr [Link nullAttr content (makeTarget targetId)]
    f b = b
    makeTarget i = ("#" <> i, "")

processEmbedLinks :: Pandoc -> Pandoc
processEmbedLinks = walk f
  where
    f (Para [Link (ident, classes, kvs) [Str "embed"] (url, title)])
      | not (Text.null title),
        Just description <- lookup "description" kvs =
        Div
          (ident, classes, filter ((/= "description") . fst) kvs)
          [ RawBlock
              "html"
              [text|<article class="link-embed" data-url="${url}">
              <header><h4><a href="${url}">${title}</a></h4></header>
              <p>${description}</p>
              <footer><small><a href="${url}">${url}</a></small></footer>
            </article>|]
          ]
    f b = b
