{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Reflex.Dom.SemanticUI.Paragraph where

import Data.Default
import Data.Text (Text)
import Data.Map (Map)
import Reflex
import Reflex.Dom.Core

import Reflex.Dom.Active
import Reflex.Dom.SemanticUI.Common
import Reflex.Dom.SemanticUI.Transition

paragraph :: MonadWidget t m => m a -> m a
paragraph = uiElement "p" def

hyperlink :: MonadWidget t m
      => Active t (Maybe Text) -> Active t Text -> m (Event t ())
hyperlink mUrl t = do
  (e, _) <- uiElement' "a" conf $ activeText t
  return $ domEvent Click e
    where conf = def { _attrs = fmap mkAttrs mUrl }
          mkAttrs :: Maybe Text -> Map Text Text
          mkAttrs Nothing = mempty
          mkAttrs (Just url) = "href" =: url

httpLink :: MonadWidget t m => Text -> m a -> m a
httpLink url child = uiElement "a" conf child
    where conf = def { _attrs = pure $ "href" =: url }
