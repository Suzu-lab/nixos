# Declarative secret management via sops-nix (https://github.com/Mic92/sops-nix).
#
# Secrets live ENCRYPTED in secrets/secrets.yaml (safe to commit to the public repo). The age
# private key that decrypts them lives ONLY on this machine at ~/.config/sops/age/keys.txt and is
# never committed. At activation, sops-nix decrypts each declared secret into /run/secrets/<name>
# (a root-owned tmpfs) with the owner/mode set below — so plaintext secrets never hit persistent
# disk in the repo.
#
# Add a secret:  edit secrets/secrets.yaml (see the command in .sops.yaml), add a `sops.secrets.<name>`
# block here, reference config.sops.secrets.<name>.path (a file) wherever it's consumed.
{
  config,
  inputs,
  username,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    # The machine-local decryption key (generated with age-keygen, kept out of the repo).
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    # CivitAI API token — consumed by host-side model downloads (see modules/ai/imagegen/README.md),
    # which read it from /run/secrets/civitai_api_token. Owned by the user so no sudo is needed.
    secrets.civitai_api_token.owner = username;

    # Hugging Face API token — for authenticated `hf` downloads (higher rate limits / faster). Read
    # via HF_TOKEN_PATH pointing at this file (set in modules/ai/model-tools.nix); the value never
    # enters the nix store. Owned by the user so `hf` needs no sudo.
    secrets.hf_token.owner = username;

    # SearXNG's server.secret_key. Not read directly — it's injected into the SearXNG config by the
    # template below (a value-only secret embedded in a config file → needs templating).
    secrets.searxng_secret_key = { };

    # Render SearXNG's settings.yml with the secret substituted for the @SECRET_KEY@ placeholder in
    # the repo file, and mount THIS rendered result into the container (see companion/docker-compose.yml,
    # which mounts /run/secrets/rendered/searxng-settings.yml). Keeps the real key out of the repo.
    templates."searxng-settings.yml" = {
      content =
        builtins.replaceStrings [ "@SECRET_KEY@" ] [ config.sops.placeholder.searxng_secret_key ]
          (builtins.readFile ../ai/companion/searxng-settings.yml);
      # SearXNG's localhost-only CSRF key; 0444 lets the container's user read the bind-mounted file
      # regardless of its uid, and world-readable in /run tmpfs is acceptable for this low-risk secret.
      mode = "0444";
    };
  };
}
