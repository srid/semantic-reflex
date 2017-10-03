{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE GADTs                #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE QuasiQuotes          #-}
{-# LANGUAGE RecursiveDo          #-}
{-# LANGUAGE RecordWildCards      #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TemplateHaskell      #-}

module Example.Section.Menu where

import GHC.Tuple -- TH requires this for (,)
import Control.Lens
import Control.Monad ((<=<), void, when, join)
import Data.Text (Text)
import qualified Data.Text as T
import Reflex.Dom.SemanticUI

import Example.QQ
import Example.Common

data Favourite
  = Haskell
  | Semantic
  | Reflex
  deriving (Eq, Show)

menu :: forall t m. MonadWidget t m => Section m
menu = LinkedSection "Menu" "A menu displays grouped navigation actions" $ do

  el "p" $ text "In Semantic UI menus are just exposed as styling elements and any active state must be managed by you. Here the current state is managed for you, providing a standalone widget which returns the currently selected value and the results of any sub widgets in a 'HList'."

  $(printDefinition stripParens ''Menu)
  $(printDefinition stripParens ''MenuDef)
  $(printDefinition id ''MenuItems)

  $(printDefinition stripParens ''MenuConfig)
  $(printDefinition stripParens ''MenuItemConfig)

  exampleCardDyn id "Header" "A menu item may include a header or may itself be a header" [mkExample|
  \resetEvent -> do
    (selected, HNil) <- ui $ Menu
      ( SubMenu (constDyn $ part $ Header H3 (text "Products") $ def & header .~ ContentHeader)
        ( MenuItem "Enterprise" "Enterprise" def
        $ MenuItem "Consumer" "Consumer" def
        $ MenuBase )
      $ SubMenu (constDyn $ part $ Header H3 (text "CMS Solutions") $ def & header .~ ContentHeader)
        ( MenuItem "Rails" "Rails" def
        $ MenuItem "Python" "Python" def
        $ MenuItem "PHP" "PHP" def
        $ MenuBase )
      $ SubMenu (constDyn $ part $ Header H3 (text "Hosting") $ def & header .~ ContentHeader)
        ( MenuItem "Shared" "Shared" def
        $ MenuItem "Dedicated" "Dedicated" def
        $ MenuBase )
      $ SubMenu (constDyn $ part $ Header H3 (text "Support") $ def & header .~ ContentHeader)
        ( MenuItem "E-mail Support" "E-mail Support" def
        $ MenuItem "FAQs" "FAQs" def
        $ MenuBase )
      $ MenuBase )
      $ def & vertical .~ True & setValue .~ (Nothing <$ resetEvent)
    return (selected :: Dynamic t (Maybe Text))
   |]

  exampleCardDyn id "Sub Menu" "A menu item may contain another menu nested inside that acts as a grouped sub-menu" [mkExample|
  \resetEvent -> do
    (selected, search `HCons` HNil) <- ui $ Menu
      ( MenuWidget ( do
        result <- ui $ Input $ def & placeholder |?~ "Search..."
        return $ result ^. value
        ) def
      $ SubMenu (constDyn $ text "Home")
        ( MenuItem "Search" "Search" def
        $ MenuItem "Add" "Add" def
        $ MenuItem "Remove" "Remove" def
        $ DropdownMenu "More"
          [ DropdownItem "Edit" "Edit" def
          , DropdownItem "Tag" "Tag" def
          ]
        $ MenuBase )
      $ MenuItem "Browse" "Browse" (def & icon ?~ Icon "grid layout" def)
      $ MenuItem "Messages" "Messages" def
      $ DropdownMenu "More"
        [ DropdownItem "Edit Profile" "Edit Profile" $ def & icon ?~ Icon "edit" def
        , DropdownItem "Choose Language" "Choose Language" $ def & icon ?~ Icon "globe" def
        , DropdownItem "Account Settings" "Account Settings" $ def & icon ?~ Icon "settings" def
        , Items "Even More"
          [ DropdownItem "Contact Us" "Contact Us" $ def & icon ?~ Icon "talk" def
          , DropdownItem "Make a Suggestion" "Make a Suggestion" $ def & icon ?~ Icon "idea" def
          ]
        ]
      $ MenuBase )
      $ def & vertical .~ True
            & setValue .~ (Nothing <$ resetEvent)
    return $ (,) <$> (selected :: Dynamic t (Maybe Text)) <*> search
   |]

  exampleCardDyn id "Arbitrary Widgets" "An item may contain an arbitrary widget with optional capture of the result" [mkExample|
  \resetEvent -> do
    let makeHeader doIcon txt = elAttr "div" ("style" =: "margin-bottom: 0.7em") $ do
          when doIcon $ void $ ui $ Icon "external" $ def & floated |?~ RightFloated
          elAttr "span" ("style" =: "font-weight: bold; text-size: 1.1em") $ text txt
        favs = map (\x -> DropdownItem (T.toLower x) x def) ["Haskell", "Semantic UI", "Reflex"]
    -- Type signature required or the value is ambiguous
    (selected :: Dynamic t (Maybe Int), fav `HCons` HNil) <- ui $ Menu
      ( MenuWidget_ ( do
          makeHeader True "Haskell"
          el "p" $ text "Purely functional programming language"
        ) (def & link .~ MenuLink "http://haskell.org/")
      $ MenuWidget_ ( do
          makeHeader True "Semantic UI"
          el "p" $ text "UI development framework designed for theming"
        ) (def & link .~ MenuLink "http://semantic-ui.com/")
      $ MenuWidget_ ( do
          makeHeader True "Reflex"
          el "p" $ text "Higher-order functional reactive programming"
        ) (def & link .~ MenuLink "http://hackage.haskell.org/package/reflex")
      $ MenuWidget ( do
          makeHeader False "Favourite"
          ui $ Dropdown favs $ pure Nothing
            & placeholder .~ "Pick your favourite..."
            & selection .~ True
            & fluid .~ True
            & setValue .~ (Nothing <$ resetEvent)
        ) (def & link .~ NoLink)
      $ MenuBase )
      $ def & vertical .~ True
    return $ (,) <$> selected <*> fav
   |]

  exampleCardDyn id "Secondary Menu" "A menu can adjust its appearance to de-emphasize its contents" [mkExample|
  \resetEvent -> do
    (selected, search `HCons` _) <- ui $ MenuDef
      ( MenuItem "Home" "Home" def
      $ MenuItem "Messages" "Messages" def
      $ MenuItem "Friends" "Friends" def
      $ RightMenu
        ( MenuWidget (ui $ Input def) (def & link .~ NoLink)
        $ MenuItem "Logout" "Logout" def
        $ MenuBase )
      $ MenuBase
      ) $ pure "Home"
        & customMenu ?~ "secondary" & setValue .~ ("Home" <$ resetEvent)
    return $ (,) <$> (selected :: Dynamic t Text) <*> search ^. value
  |]

  exampleCardDyn id "Secondary Menu" "A menu can adjust its appearance to de-emphasize its contents" [mkExample|
  \resetEvent -> do
    (selected, search `HCons` _) <- ui $ Menu
      ( MenuItem "Home" "Home" def
      $ MenuItem "Messages" "Messages" def
      $ MenuItem "Friends" "Friends" def
      $ RightMenu
        ( MenuWidget (divClass "item" $ ui $ Input def) def
        $ MenuItem "Logout" "Logout" def
        $ MenuBase)
      $ MenuBase
      ) $ def & customMenu ?~ "secondary" & setValue .~ (Nothing <$ resetEvent)
    return $ (,) <$> (selected :: Dynamic t (Maybe Text)) <*> search ^. value
  |]

  exampleCardDyn id "Vertical Menu" "A vertical menu displays elements vertically" [mkExample|
  \resetEvent -> do
    let counter txt = let widget = count <=< ui $ Button (Static txt) def :: m (Dynamic t Int)
                      in join <$> widgetHold widget (widget <$ resetEvent)
    inboxCount <- counter "Add inbox item"
    spamCount <- counter "Add spam item"
    updatesCount <- counter "Add updates item"
    let mkLabel dNum conf = Label (Dynamic $ T.pack . show <$> dNum) $ def
          & leftIcon .~ RenderWhen ((>=5) <$> dNum) (Icon "mail" def)
          & hidden .~ Dynamic (fmap (<= 0) dNum)
          & conf
          & color %~ zipActiveWith (\a b -> if a >= 10 then Just Red else b) (Dynamic dNum)
    (selected, search `HCons` HNil) <- ui $ Menu
      ( MenuItem ("inbox" :: Text) "Inbox"
          (def & color ?~ Teal
               & label ?~ mkLabel inboxCount
                  (\x -> x & color |?~ Teal & pointing |?~ LeftPointing))
      $ MenuItem "spam" "Spam" (def & label ?~ mkLabel spamCount id)
      $ MenuItem "updates" "Updates"
          (def & label ?~ mkLabel updatesCount (\x -> x & basic .~ pure True & color .~ pure (Just Black) & leftIcon .~ AlwaysRender (Icon "announcement" def)))
      $ MenuWidget (ui (Input $ def
        & icon .~ AlwaysRender (Icon "search" def)
        & placeholder |?~ "Search mail...")) def
      $ MenuBase
      ) $ def & setValue .~ (Just "Inbox" <$ resetEvent)
              & initialValue ?~ "Inbox"
              & vertical .~ True
    return $ (,) <$> selected <*> search ^. value
  |]

  return ()

