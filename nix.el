;;; small functions to help navigate nixos

(defun nix-dired (name)
  "Dir in nix store"
  (interactive (list (read-string "Nix dir: ")))
  (dired (concat "/nix/store/*" name "*")))

(defun nix-locate (name)
  "Locate in nix store"
  (interactive (list (read-string "Nix locate: ")))
  (locate (concat "/nix/store/*" name "*")))

(defun nix-pkg (name)
  "Locate nixpkg *.nix "
  (interactive (list (read-string "Nixpkg: ")))
  (locate (concat "/etc/nixos/nixpkgs/pkgs/*" name "*.nix")))

(defun nixos-module (name)
  "Find nixos *.nix "
  (interactive (list (read-string "Nixos module: ")))
  (locate (concat "/etc/nixos/nixos/modules/*" name "*.nix")))
