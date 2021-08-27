-------------------------------------------------------------------------------
-- Configuration for using xmonad inside xfce.
--
-- Author: Johannes 'wulax' Sjölund
-- Based on the work of Øyvind 'Mr.Elendig' Heggstad
--
-- Last tested with xmonad 0.15 and xfce 4.14.0
--
-- 1. Start xmonad by adding it to "Application Autostart" in xfce.
-- 2. Make sure xfwm4 and xfdesktop are disabled from autostart, or uninstalled.
-------------------------------------------------------------------------------

import qualified Data.Map as M

import qualified XMonad.StackSet as W
import Control.Exception
import System.Exit

import Control.Monad ((>=>), join, liftM, when)
import Data.Maybe (maybeToList)

import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.UpdatePointer
import XMonad.Config.Xfce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.ComboP
import XMonad.Layout.Grid
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing

-- Full screen video in Firefox --
addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]

-- Config --
conf = ewmh xfceConfig
        { manageHook        = pbManageHook <+> myManageHook
                                           <+> manageDocks
                                           <+> manageHook xfceConfig
        , layoutHook        = avoidStruts (myLayoutHook)
        , handleEventHook   = ewmhDesktopsEventHook <+> fullscreenEventHook
        , borderWidth       = 1
        , focusedBorderColor= "pink"
        , normalBorderColor = "grey"
        , workspaces        = map show [1 .. 9 :: Int]
        , modMask           = mod4Mask
        , keys              = myKeys
         }
    where
        tall                = ResizableTall 1 (3/100) (1/2) []

-- Main --
main :: IO ()
main =
    xmonad $ conf
        { startupHook       = startupHook conf
                            >> setWMName "LG3D" -- Java app focus fix
        , logHook           =  ewmhDesktopsLogHook
         }

-- Tabs theme --
myTabTheme = defaultTheme
    { activeColor           = "white"
    , inactiveColor         = "grey"
    , urgentColor           = "red"
    , activeBorderColor     = "grey"
    , inactiveBorderColor   = "grey"
    , activeTextColor       = "black"
    , inactiveTextColor     = "black"
    , decoHeight            = 22
    , fontName              = "xft:Liberation Sans:size=10"
    }

-- Layouts --
-- myLayoutHook = tile ||| rtile ||| full ||| mtile
myLayoutHook = gaps [(U,6),(D,6),(L,6),(R,6)] $ spacing 6 $ Tall 1 (2/100) (1/2)
				||| Full
  where
    rt      = ResizableTall 1 (2/100) (1/2) []
    -- normal vertical tile
    tile    = named "[]="   $ smartBorders rt
    -- normal vertical tile, master opposite side
    rtile   = named "=[]"   $ reflectHoriz $ smartBorders rt
    -- normal horizontal tile
    mtile   = named "M[]="  $ smartBorders $ Mirror rt
    -- fullscreen without tabs
    full        = named "[]"    $ noBorders Full


-- Default managers
--
-- Match a string against any one of a window's class, title, name or
-- role.
matchAny :: String -> Query Bool
matchAny x = foldr ((<||>) . (=? x)) (return False) [className, title, name, role]

-- Match against @WM_NAME@.
name :: Query String
name = stringProperty "WM_CLASS"

-- Match against @WM_WINDOW_ROLE@.
role :: Query String
role = stringProperty "WM_WINDOW_ROLE"

-- ManageHook --
pbManageHook :: ManageHook
pbManageHook = composeAll $ concat
    [ [ manageDocks ]
    , [ manageHook defaultConfig ]
    , [ isDialog --> doFloat ]
    , [ isFullscreen --> doFullFloat ]
    , [ fmap not isDialog --> doF avoidMaster ]
    ]

{-|
# Script to easily find WM_CLASS for adding applications to the list
#! /bin/sh
exec xprop -notype \
  -f WM_NAME        8s ':\n  title =\? $0\n' \
  -f WM_CLASS       8s ':\n  appName =\? $0\n  className =\? $1\n' \
  -f WM_WINDOW_ROLE 8s ':\n  stringProperty "WM_WINDOW_ROLE" =\? $0\n' \
  WM_NAME WM_CLASS WM_WINDOW_ROLE \
  ${1+"$@"}
-}
myManageHook :: ManageHook
myManageHook = composeAll [ matchAny v --> a | (v,a) <- myActions]
    where myActions =
            [ ("Xfrun4"                         , doFloat)
            , ("Xfce4-notifyd"                  , doIgnore)
            , ("MPlayer"                        , doFloat)
            , ("FLTK"                           , doFloat)
            , ("mpv"                            , doFloat)
            , ("gimp-image-window"              , (ask >>= doF . W.sink))
            , ("gimp-toolbox"                   , (ask >>= doF . W.sink))
            , ("gimp-dock"                      , (ask >>= doF . W.sink))
            , ("gimp-image-new"                 , doFloat)
            , ("gimp-toolbox-color-dialog"      , doFloat)
            , ("gimp-layer-new"                 , doFloat)
            , ("gimp-vectors-edit"              , doFloat)
            , ("gimp-levels-tool"               , doFloat)
            , ("preferences"                    , doFloat)
            , ("gimp-keyboard-shortcuts-dialog" , doFloat)
            , ("gimp-modules"                   , doFloat)
            , ("unit-editor"                    , doFloat)
            , ("screenshot"                     , doFloat)
            , ("gimp-message-dialog"            , doFloat)
            , ("gimp-tip-of-the-day"            , doFloat)
            , ("plugin-browser"                 , doFloat)
            , ("procedure-browser"              , doFloat)
            , ("gimp-display-filters"           , doFloat)
            , ("gimp-color-selector"            , doFloat)
            , ("gimp-file-open-location"        , doFloat)
            , ("gimp-color-balance-tool"        , doFloat)
            , ("gimp-hue-saturation-tool"       , doFloat)
            , ("gimp-colorize-tool"             , doFloat)
            , ("gimp-brightness-contrast-tool"  , doFloat)
            , ("gimp-threshold-tool"            , doFloat)
            , ("gimp-curves-tool"               , doFloat)
            , ("gimp-posterize-tool"            , doFloat)
            , ("gimp-desaturate-tool"           , doFloat)
            , ("gimp-scale-tool"                , doFloat)
            , ("gimp-shear-tool"                , doFloat)
            , ("gimp-perspective-tool"          , doFloat)
            , ("gimp-rotate-tool"               , doFloat)
            , ("gimp-open-location"             , doFloat)
            , ("gimp-file-open"                 , doFloat)
            , ("animation-playbac"              , doFloat)
            , ("gimp-file-save"                 , doFloat)
            , ("file-jpeg"                      , doFloat)
            ]

-- Helpers --
-- avoidMaster:  Avoid the master window, but otherwise manage new windows normally
avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
    W.Stack t [] (r:rs) -> W.Stack t [r] rs
    otherwise           -> c

-- Keyboard --
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launching and killing programs
    [ ((modMask,                xK_Return   ), spawn "kitty")
    , ((modMask,                xK_o        ), spawn "rofi -show run")
    , ((modMask .|. shiftMask,  xK_o        ), spawn "rofi -show file-browser-extended")
    , ((modMask .|. controlMask,xK_o        ), spawn "rofi -show calc")
    , ((modMask .|. controlMask,xK_Return   ), spawn "thunar")
    , ((modMask .|. shiftMask,  xK_period   ), spawn "1password")
    , ((modMask,                xK_t        ), spawn "firefox")
    , ((modMask,                xK_g        ), spawn "emacsclient -nqc")
    , ((modMask,                xK_s        ), spawn "slack")
    , ((modMask,                xK_d        ), spawn "discord")
    , ((modMask,                xK_f        ), spawn "pcmanfm .")
    , ((modMask .|. shiftMask,  xK_c        ), spawn "xkill")
    , ((modMask .|. shiftMask,  xK_q        ), spawn "xflock4")
    , ((modMask .|. shiftMask,  xK_m        ), spawn "kdocker -f")
    , ((modMask,                xK_q        ), kill)
    , ((modMask,                xK_b        ), sendMessage ToggleStruts)

    -- layouts
    , ((modMask,                xK_space    ), sendMessage NextLayout)
    , ((modMask .|. shiftMask,  xK_space    ), setLayout $ XMonad.layoutHook conf)

    -- floating layer stuff
    , ((mod1Mask .|. shiftMask, xK_t        ), withFocused $ windows . W.sink)

    -- refresh
    , ((modMask,                xK_r        ), refresh)

    -- focus
    , ((modMask,                xK_Tab      ), windows W.focusDown)
    , ((modMask,                xK_j        ), windows W.focusDown)
    , ((modMask,                xK_k        ), windows W.focusUp)
    , ((modMask,                xK_m        ), windows W.focusMaster)
    , ((modMask,                xK_Right    ), nextWS)
    , ((modMask,                xK_Left     ), prevWS)
    , ((modMask .|. shiftMask,  xK_Right    ), shiftToNext >> nextWS)
    , ((modMask .|. shiftMask,  xK_Left     ), shiftToPrev >> prevWS)

    -- swapping
    , ((modMask .|. shiftMask,  xK_Return   ), windows W.swapMaster)
    , ((modMask .|. shiftMask,  xK_j        ), windows W.swapDown)
    , ((modMask .|. shiftMask,  xK_k        ), windows W.swapUp)
    -- , ((modMask,                xK_s        ), sendMessage $ SwapWindow)

    -- increase or decrease number of windows in the master area
    , ((modMask,                xK_comma    ), sendMessage (IncMasterN 1))
    , ((modMask,                xK_period   ), sendMessage (IncMasterN (-1)))

    -- resizing
    , ((modMask,                xK_h        ), sendMessage Shrink)
    , ((modMask,                xK_l        ), sendMessage Expand)
    , ((modMask .|. shiftMask,  xK_h        ), sendMessage MirrorShrink)
    , ((modMask .|. shiftMask,  xK_l        ), sendMessage MirrorExpand)

    -- quit, or restart
    , ((modMask .|. controlMask,xK_q        ), spawn "xmonad --restart")
    , ((mod1Mask .|. shiftMask,  xK_q        ), spawn "xfce4-session-logout")
    , ((modMask .|. shiftMask, xK_x        ), spawn "xscreensaver-command -lock")

    -- ungrab mouse cursor from applications which can grab it (games)
    , ((modMask,                xK_i        ), spawn "xdotool key XF86Ungrab")
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [ ((m .|. modMask, k), windows $ f i)
    | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]
    ++
    -- mod-{w,e,r} %! Switch to physical/Xinerama scjeens 1, 2, or 3
    -- mod-shift-{w,e,r} %! Move client to screen 1, 2, or 3
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_e, xK_w, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

