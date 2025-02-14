{ ... }:

{
  programs.nixcord = {
    enable = true;
    discord.enable = true;
    vesktop.enable = true;
    config = {
      disableMinSize = true;
      plugins = {
        accountPanelServerProfile.enable = true;
        alwaysTrust = {
          enable = true;
          file = true;
        };
        anonymiseFileNames = {
          enable = true;
          anonymiseByDefault = true;
          method = "consistent";
        };
        betterRoleContext.enable = true;
        betterRoleDot.enable = true;
        betterSessions.enable = true;
        betterSettings = {
          enable = true;
          disableFade = false;
        };
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        callTimer.enable = true;
        clearURLs.enable = true;
        copyEmojiMarkdown.enable = true;
        copyFileContents.enable = true;
        customIdle.enable = true;
        emoteCloner.enable = true;
        experiments.enable = true;
        fakeNitro = {
          enable = true;
          enableStreamQualityBypass = false;
        };
        favoriteGifSearch.enable = true;
        fixImagesQuality.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        fullSearchContext.enable = true;
        fullUserInChatbox.enable = true;
        greetStickerPicker = {
          enable = true;
          greetMode = "Message";
        };
        imageZoom.enable = true;
        memberCount.enable = true;
        messageClickActions.enable = true;
        messageLatency.enable = true;
        messageLinkEmbeds.enable = true;
        messageLogger.enable = true;
        moreCommands.enable = true;
        moreKaomoji.enable = true;
        mutualGroupDMs.enable = true;
        noOnboardingDelay.enable = true;
        noPendingCount = {
          enable = true;
          hideFriendRequestsCount = false;
          hideMessageRequestCount = false;
        };
        noUnblockToJump.enable = true;
        onePingPerDM = {
          enable = true;
          allowMentions = true;
        };
        openInApp = {
          enable = true;
          spotify = true;
          steam = true;
        };
        permissionFreeWill.enable = true;
        permissionsViewer.enable = true;
        petpet.enable = true;
        platformIndicators.enable = true;
        previewMessage.enable = true;
        replaceGoogleSearch = {
          enable = true;
          customEngineName = "DDG";
          customEngineURL = "https://duckduckgo.com/?q=";
        };
        serverInfo.enable = true;
        showHiddenThings.enable = true;
        showTimeoutDuration.enable = true;
        silentMessageToggle = {
          enable = true;
          persistState = true;
          autoDisable = false;
        };
        silentTyping = {
          enable = true;
          showIcon = true;
          isEnabled = false;
        };
        spotifyCrack = {
          enable = true;
          keepSpotifyActivityOnIdle = true;
        };
        spotifyControls = {
          enable = true;
          useSpotifyUris = true;
        };
        spotifyShareCommands.enable = true;
        streamerModeOnStream.enable = true;
        typingIndicator.enable = true;
        typingTweaks.enable = true;
        unlockedAvatarZoom.enable = true;
        userVoiceShow.enable = true;
        validReply.enable = true;
        validUser.enable = true;
        vencordToolbox.enable = true;
        viewIcons = {
          enable = true;
          format = "png";
        };
        voiceChatDoubleClick.enable = true;
        voiceDownload.enable = true;
        voiceMessages.enable = true;
        volumeBooster.enable = true;
        webKeybinds.enable = true;
        webScreenShareFixes.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
      };
    };
  };
}
