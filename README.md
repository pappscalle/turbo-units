# turbo-units
A collection of common Turbo Pascal 7 units, to be used for retro-style coding in Mode 13h.

This repo can be used on its own, but it is also used as subtree in other repos.

A repo that uses this as a submodule should update the submodule like this:
```
git submodule update --remote --merge
git add src/external
git commit -m "Update turbo-units submodule"
git push
```
