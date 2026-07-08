# Pipewire audio system configuration
{ config, lib, ... }:
let
  cfg = config.suzu.system.audio;
in
{
  options.suzu.system.audio.enable = lib.mkEnableOption "PipeWire audio stack";

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;

      # USB audio fix. The Fifine mic exposes a playback ("sink") interface it
      # never uses, and at boot WirePlumber sometimes picks it as the default
      # output — breaking audio (and apps like Steam that choke on it). We:
      #   1. force the Fifine card to an input-only profile (no sink at all),
      #   2. belt-and-suspenders: disable the Fifine output node in case a
      #      duplex profile gets restored from saved state, and
      #   3. give the Shanling UA2 DAC a high priority so it's always the
      #      preferred default output.
      wireplumber.extraConfig."51-usb-audio-fix" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "alsa_card.usb-MV-SILICON_fifine_Microphone_20190808-00"; }
            ];
            actions.update-props."device.profile" = "input:analog-stereo";
          }
          {
            matches = [
              { "node.name" = "alsa_output.usb-MV-SILICON_fifine_Microphone_20190808-00.analog-stereo"; }
            ];
            actions.update-props."node.disabled" = true;
          }
          {
            matches = [
              { "node.name" = "alsa_output.usb-Shanling_UA2_Shanling_UA2_Shanling_UA2-00.analog-stereo"; }
            ];
            actions.update-props = {
              "priority.session" = 2000;
              "priority.driver" = 2000;
            };
          }
        ];
      };
    };
  };
}
