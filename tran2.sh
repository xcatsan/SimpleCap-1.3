#!/bin/sh
BIN="/Developer Tools/Xcode and iOS SDK 3.2.5/usr/bin/ibtool"
"$BIN" --strings-file Japanese.lproj/MainMenu.strings --write Japanese.lproj/MainMenu.nib English.lproj/MainMenu.nib

"$BIN" --strings-file zh_TW.lproj/MainMenu.strings --write zh_TW.lproj/MainMenu.nib English.lproj/MainMenu.nib

"$BIN" --strings-file Italian.lproj/MainMenu.strings --write Italian.lproj/MainMenu.nib English.lproj/MainMenu.nib

"$BIN" --strings-file French.lproj/MainMenu.strings --write French.lproj/MainMenu.nib English.lproj/MainMenu.nib

"$BIN" --strings-file Portuguese.lproj/MainMenu.strings --write Portuguese.lproj/MainMenu.nib English.lproj/MainMenu.nib
