;;; small functions to help navigate nixos

(defun nix-dired (name)
  "Dir in nix store"
  (interactive (list (read-string "Nix dir: ")))
  (dired (concat "/nix/store/*" name "*")))

(defun nix-locate (name)
  "Locate in nix store"
  (interactive (list (read-string "Nix locate: ")))
  (locate (concat "/nix/store/*" name "*")))
