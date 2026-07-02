# IGP-Deep-Dive — Handoff

_Last updated: 2026-07-02_

## Status
- Lab is **built** but **not yet tested in EVE-NG** (per project status table).
- Folder is **not yet a git repo**. Target: push to a new empty GitHub repo `bosamart/IGP-Deep-Dive`.

## Contents
```
IGP-Deep-Dive/
├── README.md              # main phased writeup
├── configs/               # IS-IS final-state configs
│   ├── R1.txt R2.txt R3.txt R4.txt
│   └── ospf/              # OSPF comparison configs (R1–R4)
├── diagrams/topology.md
├── docs/                  # CONCEPTS, FAST-CONVERGENCE, ISIS-vs-OSPF, METRICS-AND-LEVELS
└── notes/                 # phase1–phase6 verify logs + README
```

## Push to GitHub (do from this folder)
```bash
cd "C:\Users\ATH\Claude\Projects\Network-Engineering\Labs\IGP-Deep-Dive"

git init
git add .
git commit -m "Initial commit: IGP-Deep-Dive lab (IS-IS + OSPF)"
git branch -M main
```

Create the empty repo on github.com (name `IGP-Deep-Dive`, **no** README/license), then:
```bash
git remote add origin https://github.com/bosamart/IGP-Deep-Dive.git
git push -u origin main
```
Password prompt = your Personal Access Token (not account password).

GitHub CLI alternative (creates repo + pushes in one line):
```bash
gh repo create bosamart/IGP-Deep-Dive --public --source=. --remote=origin --push
```

## Notes / gotchas
- Keep the new repo empty on creation, or the first push is rejected for unrelated histories.
  If that happens: `git pull --rebase origin main` then push again.
- Do NOT `git clone` into the project folder from the sandbox — it doesn't sync to real files.
- After pushing, update the status table in `../../CLAUDE.md` and the repo list.

## Next / TODO
- [ ] Test the lab in EVE-NG (XRv9000 ~24.3.1), paste real `show` output into `notes/`.
- [ ] Push to GitHub (above).
- [ ] Add repo link to project README once live.
