{ user, ... }:

{
  power.restartAfterFreeze = true;

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 15;
      KeyRepeat = 3;

      # Finder sidebar icons: 1 small, 2 medium, 3 large.
      NSTableViewDefaultSizeMode = 3;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSWindowShouldDragOnGesture = true;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.scaling" = 1.5;
    };

    ".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;

    # OmniWM needs separate Spaces for each display. A change requires logout.
    spaces.spans-displays = false;
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 0;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadFourFingerHorizSwipeGesture = 0;
    };

    finder = {
      ShowStatusBar = true;
      ShowPathbar = true;
      _FXSortFoldersFirst = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv"; # Column view.
    };

    dock = {
      expose-animation-duration = 0.1;
      expose-group-apps = true;
      mru-spaces = false;
      autohide = true;
      # On purpose: a 100 s delay keeps the hidden Dock from appearing on hover.
      autohide-delay = 100.0;
      show-recents = false;
      tilesize = 44;
    };

    ActivityMonitor = {
      OpenMainWindow = true;
      IconType = 5;
      ShowCategory = 100; # All processes.
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    # On purpose: no "downloaded from the internet" prompts.
    LaunchServices.LSQuarantine = false;

    CustomUserPreferences = {
      NSGlobalDomain = {
        NSColorSimulateHardwareAccent = true;
        NSColorSimulatedHardwareEnclosureNumber = 4;
        "com.apple.scrollwheel.scaling" = 0.75;
      };
      "com.apple.print.PrintingPrefs"."Quit When Finished" = true;
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.frameworks.diskimages" = {
        # On purpose: skip disk-image verification.
        skip-verify = true;
        skip-verify-locked = true;
        skip-verify-remote = true;
        auto-open-ro-root = true;
        auto-open-rw-root = true;
      };
      "com.apple.finder" = {
        OpenWindowForNewRemovableDisk = true;
        FXInfoPanesExpanded = {
          General = true;
          OpenWith = true;
          Privileges = true;
        };
      };
      "com.apple.dock".no-bouncing = true;
      "com.apple.Safari" = {
        ShowFullURLInSmartSearchField = true;
        FindOnPageMatchesWordStartsOnly = false;
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        CanPromptForPushNotifications = false;
      };
      "com.apple.mail".AddressesIncludeNameOnPasteboard = false;
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
      "com.apple.TextEdit" = {
        RichText = 0;
        PlainTextEncoding = 4;
        PlainTextEncodingForWrite = 4;
      };
      "com.apple.QuickTimePlayerX".MGPlayMovieOnOpen = true;
      "com.google.Chrome".DisablePrintPreview = true;
      "com.apple.dt.Xcode" = {
        CodeFoldingAnimationSpeed = 0;
        ShowBuildOperationDuration = true;
      };
    };

    # Software Update reads system preferences, not the user's preference file.
    CustomSystemPreferences."/Library/Preferences/com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      AutomaticDownload = true;
      CriticalUpdateInstall = true;
    };
  };

  # Image Capture reads this key from the -currentHost (ByHost) domain, which
  # nix-darwin cannot write. Home Manager can. `defaults import` replaces the
  # domain; it holds only this key.
  home-manager.users.${user.name}.targets.darwin.currentHostDefaults."com.apple.ImageCapture".disableHotPlug =
    true;
}
