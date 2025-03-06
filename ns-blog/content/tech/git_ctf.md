+++
title = "git ctf"
date = "2025-03-05T20:13:59-05:00"

tags = ["blog","tech","git", "ctf", "git_ctf"]
+++
this is my write up for [`git ctf`](https://www.mrnice.dev/ctf/), a set of challenges centered around `git` operations

TLDR:
- every flag is the name of a git branch that you can checkout to start the relevant challenge
## clone
```sh
> ssh player@ctf.mrnice.dev -p 12345
```
password is `player`
```sh
> git clone gamemaster@localhost:~/ctf-repo
> cat README.md
Now, to proceed - `git checkout` the branch named `start-here`, and then read me again.
```
## start-here
```sh
> cat README.md
1. Add 2 files to the root of the repo: `alice.txt` and `bob.txt`.
2. Commit your changes (should be only one commit!).
3. Push your changes to the remote repo.
4. If you did it right, you should get your flag.
```

```sh
> touch alice.txt bob.txt
> git add .
> gc -m 'new files'
> git push
remote: -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
remote: 
remote: Pushed a branch: start-here
remote: 
remote:         ()__
remote:         ||  Z__
remote:         ||  |   Z____
remote:         ||  |   |    |
remote:         ||  |   |    |
remote:         ||__|   |    |
remote:         ||  /___|    |
remote:         ||      /____/
remote:         ||
remote:         ||
remote:         ||
remote:         /\                
remote:     ___/  \___
remote: 
remote: You won! The flag is scorpion-treenware-gestatory (basic-1)
remote: 
remote: -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
remote: 
```

flag = `scorpion-treenware-gestatory`
## basic
### basic-1
```sh
> cat README.md
To solve this level you need to remove the file called `deleteme.txt`.
```

```sh
> l
-rw-r--r-- 1 player player   72 Feb 28 04:46 README.md
-rw-r--r-- 1 player player   32 Feb 28 04:52 deleteme.txt
-rw-r--r-- 1 player player   27 Feb 28 04:46 dontdeleteme.txt

> rm deleteme.txt
> ga .
> gc -m 'delete'
> git push
remote: You won! The flag is sidespins-areae-regalio (basic-2)
```
flag = `sidespins-areae-regalio`

### basic-2
```sh
> cat README.md
To solve this level, you need to add two new files (call them whatever you want) under a directory called `newdir`.
> mkdir newdir
> touch newdir/one.txt newdir/two.txt
> ga .
> gc -m 'dir files'
> git push
remote: You won! The flags are
remote: macrochiropteran-jupon-lutecium (merge-1)
remote: turbulator-feere-reinclined (log-1)
```
flags = `macrochiropteran-jupon-lutecium` & `turbulator-feere-reinclined`

## merge
### merge-1
```sh
> cat README.md
Take a look at the runme.py script. It's unfinished, and the rest of the work is in another **branch**...

(There's no need to edit files to solve this level. Only git commands will suffice.)
```

now we finally have more an involved challenge. Let's take a look at `runme.py`

```py runme.py
#!/usr/bin/env python3

def print_something_cool():
    # I'll finish the rest of the work in another branch... zZzZ
    raise NotImplementedError("I'll implement the rest of this script in the steek-shabandar-taenifuge branch.")

def main():
    print_something_cool()

if __name__ == "__main__":
    main()
```

```sh
> gco steek-shabandar-taenifuge
```
This branch also has a `runme.py` file
```py
#!/usr/bin/env python3

import base64

def print_something_cool():
    something_cool = b'CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgXy4tIi0uXwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBfLi0iLS5fJyAgICAgICBgLS5fCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBfLi0iLS5fJyAgICAgICBgLS5fICAgICBfLi0nfAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIF8uLSItLl8nICAgICAgIGAtLl8gICAgIF8uLXxfLi0nXy4tJ2AtLl8KICAgICAgICAgICAgICAgICAgICAgXy4tIi0uXycgICAgICAgYC0uXyAgICAgXy4tfF8uLScgICB8Xy4tJyAgICAgICAgYC0uXwogICAgICAgICAgICAgXy4tIi0uXycgICAgICAgYC0uXyAgICAgXy4tfF8uLScgICAgICAgICAgIGAtLl8gICAgICAgICBfLi18CiAgICAgXy4tIi0uXycgICAgICAgYC0uXyAgICAgXy4tfF8uLScgICAgICAgICAgICAgICAgICAgICAgIGAtLl8gXy4tJ18uLWAtLl8KIF8uLScgICAgICAgYF8uLSItLl8gXy4tfF8uLScgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHxfLi0nICAgICAgIGAtLl8KYC0uXyAgICAgXy4tJyAgICAgICBgXy4tJy0uXyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwtLl8gICAgICAgICBfLi0nCiAgICBgLS5ffC0uXyAgICAgXy4tJyAgICAgICBgXy4tJy0uXyAgICAgICAgICAgICAgICAgICAgICAgICBfLi0nLS5fYC0uXyBfLi0nCiAgICAgICAgICAgIGAtLl98LS5fICAgICBfLi0nICAgICAgIGBfLi0nLS5fICAgICAgICAgICAgIF8uLScgICAgICAgYC0uX3wKICAgICAgICAgICAgICAgICAgICBgLS5ffC0uXyAgICAgXy4tJyAgICAgICBgXy4tJy0uXyAgICB8LS5fICAgICAgICAgXy4tJwogICAgICAgICAgICAgICAgICAgICAgICAgICAgYC0uX3wtLl8gICAgIF8uLScgICAgICAgYF8uLSctLl9gLS5fIF8uLScKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYC0uX3wtLl8gICAgIF8uLScgICAgICAgYC0uX3wKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBgLS5ffC0uXyAgICAgICAgIF8uLScKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGAtLl8gXy4tJyAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIgo=CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgXy4tIi0uXwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBfLi0iLS5fJyAgICAgICBgLS5fCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBfLi0iLS5fJyAgICAgICBgLS5fICAgICBfLi0nfAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIF8uLSItLl8nICAgICAgIGAtLl8gICAgIF8uLXxfLi0nXy4tJ2AtLl8KICAgICAgICAgICAgICAgICAgICAgXy4tIi0uXycgICAgICAgYC0uXyAgICAgXy4tfF8uLScgICB8Xy4tJyAgICAgICAgYC0uXwogICAgICAgICAgICAgXy4tIi0uXycgICAgICAgYC0uXyAgICAgXy4tfF8uLScgICAgICAgICAgIGAtLl8gICAgICAgICBfLi18CiAgICAgXy4tIi0uXycgICAgICAgYC0uXyAgICAgXy4tfF8uLScgICAgICAgICAgICAgICAgICAgICAgIGAtLl8gXy4tJ18uLWAtLl8KIF8uLScgICAgICAgYF8uLSItLl8gXy4tfF8uLScgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHxfLi0nICAgICAgIGAtLl8KYC0uXyAgICAgXy4tJyAgICAgICBgXy4tJy0uXyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwtLl8gICAgICAgICBfLi0nCiAgICBgLS5ffC0uXyAgICAgXy4tJyAgICAgICBgXy4tJy0uXyAgICAgICAgICAgICAgICAgICAgICAgICBfLi0nLS5fYC0uXyBfLi0nCiAgICAgICAgICAgIGAtLl98LS5fICAgICBfLi0nICAgICAgIGBfLi0nLS5fICAgICAgICAgICAgIF8uLScgICAgICAgYC0uX3wKICAgICAgICAgICAgICAgICAgICBgLS5ffC0uXyAgICAgXy4tJyAgICAgICBgXy4tJy0uXyAgICB8LS5fICAgICAgICAgXy4tJwogICAgICAgICAgICAgICAgICAgICAgICAgICAgYC0uX3wtLl8gICAgIF8uLScgICAgICAgYF8uLSctLl9gLS5fIF8uLScKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYC0uX3wtLl8gICAgIF8uLScgICAgICAgYC0uX3wKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBgLS5ffC0uXyAgICAgICAgIF8uLScKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGAtLl8gXy4tJyAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIgo='

    print(base64.b64decode(something_cool).decode())

def main():
    print_something_cool()

if __name__ == "__main__":
    main()
```
let's see what this outputs when we run it
```sh
> python runme.py

                                                     _.-"-._
                                             _.-"-._'       `-._
                                     _.-"-._'       `-._     _.-'|
                             _.-"-._'       `-._     _.-|_.-'_.-'`-._
                     _.-"-._'       `-._     _.-|_.-'   |_.-'        `-._
             _.-"-._'       `-._     _.-|_.-'           `-._         _.-|
     _.-"-._'       `-._     _.-|_.-'                       `-._ _.-'_.-`-._
 _.-'       `_.-"-._ _.-|_.-'                                   |_.-'       `-._
`-._     _.-'       `_.-'-._                                    |-._         _.-'
    `-._|-._     _.-'       `_.-'-._                         _.-'-._`-._ _.-'
            `-._|-._     _.-'       `_.-'-._             _.-'       `-._|
                    `-._|-._     _.-'       `_.-'-._    |-._         _.-'
                            `-._|-._     _.-'       `_.-'-._`-._ _.-'
                                    `-._|-._     _.-'       `-._|
                                            `-._|-._         _.-'
                                                    `-._ _.-'  
                                                        "

```
Hmm not sure what to do with that. Let's take a look at the `git log`
```sh
> git log
commit 916cd9d5ca15e8f09e1b44fdc43d4bc955915715 (HEAD -> steek-shabandar-taenifuge, tag: steek-shabandar-taenifuge-tag, origin/steek-shabandar-taenifuge)
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Mon Jun 1 22:33:51 2020 +0300

    Finished working on the runme script. Merge me into macrochiropteran-jupon-lutecium branch.
```
Ah need to merge these branches together
```sh
> gco macrochiropteran-jupon-lutecium
> git merge steek-shabandar-taenifuge
> ga .
> gc -m 'merged'
> git push
remote: You won! The flag is poseuse-citronwood-manganese (merge-2)
```
flag = `poseuse-citronwood-manganese`

### merge-2
```sh
> cat README.md
Take a look at the runme.py script. It's unfinished, and the rest of the work is in another **branch**...

(There's no need to edit files to solve this level. Only git commands will suffice.)
```
getting a sense of *deja-vu...*
```sh
> cat runme.py
#!/usr/bin/env python3

import base64
import os

def print_something_cool():
    something_cool = <some base64 encoded stuffs>

    # I'll define cool file in the cannoneer-dephlegm-holoptychius branch.
    assert os.path.exists("./cool_file"), "couldn't find cool file: It's in the cannoneer-dephlegm-holoptychius branch"

    print(base64.b64decode(something_cool).decode())

def main():
    print_something_cool()

if __name__ == "__main__":
    main()
```
time to go to another branch
```sh
> gco cannoneer-dephlegm-holoptychius
> l
...
-rw-r--r-- 1 player player   57 Feb 28 05:19 cool_file
```
this branch has a new file `cool_file`, let's merge that into the first branch and see what happens
```sh
> gco poseuse-citronwood-manganese
> git merge cannoneer-dephlegm-holoptychius
> git push
remote: You won! The flags are
remote: twee-enfamish-stropharia (merge-3)
remote: parallelizing-barnhardtite-base (rebase-1)
```
success!
flags = `twee-enfamish-stropharia` & `parallelizing-barnhardtite-base`

### merge-3
```sh
> cat README.md
Take a look at the runme.py script. It's unfinished, and the rest of the work is in another **branch** (gemstone-introrsely-gouts). But this time, things aren't so harmonious. Don't panic!

(You can edit files to solve this level. Only git commands will suffice.)
```
(I assume that the last line is a typo and that I don't need to edit files)

```sh
> gco gemstone-introrsely-gouts
```
nothing special, just another version of the `runme.py` file. let's `git merge` again and see what happens
```sh
> gco twee-enfamish-stropharia
> git merge gemstone-introrsely-gouts
Auto-merging runme.py
CONFLICT (content): Merge conflict in runme.py
Automatic merge failed; fix conflicts and then commit the result.
```
merge conflict ☹, okay maybe we can edit the files (at least to resolve a merge conflict)

```sh
> vim runme.py
def print_another_cool_thing():
<<<<<<< HEAD
    message = "Your cool (*/?~I＼*)"
=======
    message = "You're cool (*/?~I＼*)"
>>>>>>> gemstone-introrsely-gouts
    print(message)
```
let's take the grammatically correct one
```py
def print_another_cool_thing():
    message = "You're cool (*/?~I＼*)"
    print(message)
```
time to push up again
```sh
> ga .
> gc
> git push
remote: You won! The flags are
remote: multichord-ethicalism-fenestration (merge-4)
remote: lomentaceous-mididae-hexadecane (revert-1)
```
flags = `multichord-ethicalism-fenestration` & `lomentaceous-mididae-hexadecane`

### merge-4
this time the `README.md` directly lists what branch we need to go look at, `unconvincing-mesothermal-miles`, but let's take a look at the `runme.py` first
```py
def print_yet_another_thing():
    process = subprocess.Popen(['git', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    print("The current git version you're playing with is " + stdout.decode())
```
and when trying to run it, I get an error:
```sh
Traceback (most recent call last):
  File "runme.py", line 25, in <module>
    main()
  File "runme.py", line 22, in main
    print_yet_another_thing()
  File "runme.py", line 15, in print_yet_another_thing
    process = subprocess.Popen(['git', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
NameError: name 'subprocess' is not defined
```

okay let's try to `git merge` and see what happens
```sh
> git merge unconvincing-mesothermal-miles
Auto-merging runme.py
CONFLICT (content): Merge conflict in runme.py
Automatic merge failed; fix conflicts and then commit the result.
```
another conflict again, this time it seems slightly more complicated
```sh
def print_yet_another_thing():
<<<<<<< HEAD
    process = subprocess.Popen(['git', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    print("The current git version you're playing with is " + stdout.decode())

def main():
    print_something_cool()
    print_another_cool_thing()
    print_yet_another_thing()
=======
    pass  # will implement in another branch
>>>>>>> unconvincing-mesothermal-miles
```
let's keep the fully implemented version of `print_yet_another_thing` and `main`
```sh
def print_yet_another_thing():
    process = subprocess.Popen(['git', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    print("The current git version you're playing with is " + stdout.decode())

def main():
    print_something_cool()
    print_another_cool_thing()
    print_yet_another_thing()
```

now commit, push, and
```
remote: You won! The flag is reappraise-veratroyl-garfishes (merge-5)
```
flag = `reappraise-veratroyl-garfishes`

### merge-5
lots of instructions in the `README.md` this time
```sh
Take a look at the `should_rename_this.py` script. It's finished, but the name isn't very clear about what the script does. The script was given a better name in another **branch** (vicomtesses-apery-vanillin). 

Merge the changes from that branch, ending up with: 
- The new code from the reappraise-veratroyl-garfishes branch
- The new name from the vicomtesses-apery-vanillin branch
```
I hope `git` handles renames well 🤞
```sh
> git merge vicomtesses-apery-vanillin
CONFLICT (rename/rename): Rename "runme.py"->"should_rename_this.py" in branch "HEAD" rename "runme.py"->"scripts/print_cool_stuff.py" in "vicomtesses-apery-vanillin"
Automatic merge failed; fix conflicts and then commit the result.
```
okay let's see what we are working with
```sh
> gst
On branch reappraise-veratroyl-garfishes
Your branch is up to date with 'origin/reappraise-veratroyl-garfishes'.

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add/rm <file>..." as appropriate to mark resolution)
	both deleted:    runme.py
	added by them:   scripts/print_cool_stuff.py
	added by us:     should_rename_this.py
```
looks like we can get rid of `runme.py`, the new name of the file should be `print_cool_stuff.py`, and the correct contents are in `should_rename_this.py`. normally, I'd just delete the extraneous files and manually rename the `should_rename_this.py` file, but today I'll try `git mv` since this is a `git-ctf` particularly

```sh
> ga runme.py # stages the deletion of the runme.py file
> rm scripts/princ_cool_stuff.py
> ga should_rename_this.py
> git mv should_rename_this.py scripts/print_cool_stuff.py
> gst
On branch reappraise-veratroyl-garfishes
Your branch is up to date with 'origin/reappraise-veratroyl-garfishes'.

All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

Changes to be committed:
	renamed:    should_rename_this.py -> scripts/print_cool_stuff.py
```
looks like that should do the trick, let's commit and push
```
remote: You won! The flag is merge-levels-done-you-win (final)
```
flag = `merge-levels-done-you-win`

🎉 finished all the merge levels, let's tackle [`log`](#log) next

## log
pretty clear that this section should be all about the `git log` (and maybe `reflog` too)
### log-1
```sh
> cat README.md
The next flag can be found in the commit message of the current branch's grandparent (2 commits back from now).
```
pretty straightforward challenge
```sh
> git log
...
commit e16a3e386eadfa32a6de83b6bba165e3b4eba9ad
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Tue Jun 2 17:30:30 2020 +0300

    The flag is insatiably-skyjackers-program (log-2) ^_^
```
flag = `insatiably-skyjackers-program`
### log-2
```sh
> cat README.md
The flag was hidden in one of the commit messages in the current branch's history. The commit message where it's hidden has the text "The flag is hidden here" in it.

Find it.
```
there's at least 200 commits
```sh
> git log
...
commit 72c899f49c11943ec140f88ec6d2b79ea49ce32d
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Tue Jun 2 17:45:45 2020 +0300

    commit 200

commit 283058e235fcd9acf260827dcecb7fb52c2cfd28
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Tue Jun 2 17:45:45 2020 +0300

    commit 199
```

let's use `grep` to help find the correct commit
```sh
> git log | grep "the flag" -B 10 -A 2
    commit 128

commit fae3dfb00a8f28c29e5f163dc07f3847a9a50928
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Tue Jun 2 17:41:37 2020 +0300

    commit 127
    
    THE FLAG IS HIDDEN HERE
    The flag is hidden here
    the flag is hidden here
    
    The flag is originates-anagyrine-untolerative (log-3)
--
```
flag = `originates-anagyrine-untolerative`

### log-3
```sh
> cat README.md
The flag is hidden in one of the changes in this branch's history. I wrote "The flag is ..." to a file, and then deleted it.

Find it.
```
time to find content within the commit history
```sh
> git log -p -- justafile.txt | grep flag
-The flag is belialist-interlaying-mize (log-4)
+The flag is belialist-interlaying-mize (log-4)
    The flag is hidden here
    the flag is hidden here
    The flag is originates-anagyrine-untolerative (log-3)
    Look at my grandparent commit message to find the flag...
    The flag is insatiably-skyjackers-program (log-2) ^_^
```
flag = `belialist-interlaying-mize`
### log-4
```sh
> cat README.md
The flag is hidden 198 commits before this one.

Find it, but don't start manually counting ¯\_(ツ)_/¯
```
okay so now we need something that can pick a N number of commits before
```sh
> git log HEAD~198
commit 0548382e835a5dad7e4731c6af08dc2e9eacd53d
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Tue Jun 2 23:31:23 2020 +0300

    pamphletary-harnessing-petticoaterie
```
flag = `pamphletary-harnessing-petticoaterie`
### log-5
```sh
> cat README.md
This level is not a challenge, but a code for later. 
Write down this flag: log-flag-meteorical
```
huh?

okay maybe flag = `log-flag-meteorical`

turns out this is the last log level anyways, will just keep track of this. let's tackle [`rebase`](#rebase)
## rebase
### rebase-1
things may start getting rough on this one
```sh
> cat README.md
In this level, we have a **base** branch and a **topic** branch.

The base branch is		parallelizing-barnhardtite-base
and the topic branch is		parallelizing-barnhardtite-topic
See the difference:					   ^^^^^

The base branch introduced the script which prints all the resources in the `runme_resources/` folder. 

In the topic branch, we will need to add specific resources. To do this, run the `add_resources.sh` script and commit the new changes. Make sure you also remove the `add_resources.sh` script! There's no need for it in the base branch!

We will get diverging histories. Instead of merging and pushing, we want to rebase the topic branch on the base branch, and push a clean, linear history.
```

```sh
> gco parallelizing-barnhardtite-topic
> chmod +x add_resources.sh  # the script was not executable mode
> rm add_resources.sh
> git add .
> gc -m 'changes'
> git rebase -i parallelizing-barnhardtite-base
> gco parallelizing-barnhardtite-base
> git rebase -i parallelizing-barnhardtite-topic
> git push
remote: You won! The flag is downfalling-bumbled-sootiness (rebase-2)
```

okay got this one to eventually work but not sure if I did everything perfect. I initially rebased `parallelizing-barnhardtite-topic` *on* `parallelizing-barnhardtite-base` and tried pushing but ran into an error. on closer reading of the instructions, I realized I needed to push the base branch. so I checked out the base branch, rebased the changes of the topic branch onto the base branch, and hoped for the best.

flag = `downfalling-bumbled-sootiness`
### rebase-2
```sh
> cat README.md
# rebase-2

In this level, the commits are all out of order.
Reorder them using an interactive rebase, and push
this branch with the commits in the correct order.

The correct order is:

> First base: Who
> Second base: What
> Third base: I Don't Know
```
this one seems pretty easy honestly

```sh
> git rebase -i origin/master
pick 86a5b92 updating README for the stage.
pick 32a2878 add empty "base" files
pick bd7753b What's on second
pick 8e1009e I don't know's on third
pick 376b18e Who's on first
# edit the file to move the last commit to 3rd
pick 86a5b92 updating README for the stage.
pick 32a2878 add empty "base" files
pick 376b18e Who's on first
pick bd7753b What's on second
pick 8e1009e I don't know's on third
```

```sh
> git push --force
remote: You won! The flag is rebase-levels-done-you-win (final)
```
flag = `rebase-levels-done-you-win`
`rebase` finished

## revert
### revert-1
```sh
> cat README.md
I committed some lines I didn't mean to to the runme.py file! Please undo my mistakes.
```
from the log, it's pretty clear that the most recent commit should be reverted
```sh
commit 1948a60c6ee8098fce8524b48426ec06b9938d58 (HEAD -> lomentaceous-mididae-hexadecane, tag: lomentaceous-mididae-hexadecane-tag, origin/lomentaceous-mididae-hexadecane)
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Sat Jun 6 14:33:43 2020 +0300

    Oops - didn't mean to commit this.
```

```sh
> git revert 1948a60c6ee8098fce8524b48426ec06b9938d58
> git push
remote: You won! The flag is redamage-bundh-passerina (tag-1)
```
flag = `redamage-bundh-passerina`

## tag
ngl, I have no idea what `git tags` are
### tag-1
```sh
> cat README.md
To pass this stage, push a new lightweight tag called my-new-tag that tags this commit.
```
time for some chat gpt
...
looks like they are either simple messages or rich metadata that can be attached to a commit

let's do this

```sh
> git tag my-new-tag
> git push origin my-new-tag
remote: You won! The flags are
remote: individually-nonintroversive-chalcomancy (tag-2)
remote: hands-trooshlach-nongassy (hooks-1)
```
flags = `individually-nonintroversive-chalcomancy` & `hands-trooshlach-nongassy`

### tag-2
```sh
> cat README.md
The flag is *in* the tag of the commit previous to this.
```
let's look at the log
```sh
> git log
commit bee5d7a8c47f3a2016e4558ba81aa7ece1cf0134 (tag: individually-nonintroversive-chalcomancy-flag)
Author: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Fri Jun 12 02:32:27 2020 +0300

    commit 10
```
let's see what's in this tag
```sh
> git show individually-nonintroversive-chalcomancy-flag
tag individually-nonintroversive-chalcomancy-flag
Tagger: Shay Nehmad <shay.nehmad@guardicore.com>
Date:   Fri Jun 12 02:33:43 2020 +0300

You found the flag :)

<E2><95><B0>(*<C2><B0><E2><96><BD><C2><B0>*)<E2><95><AF>

This is a final flag, write it down:

nine-botchy-remarker (final)
```

flag = `nine-botchy-remarker`

tags finished!

## hooks
### hooks-1
```sh
> cat README.md
**For this stage, you must run the script setup_hooks_stage.sh first!**

You need to add more than 100 files into the `add_files_here` directory, and you can't do it in more than 3 commits. Shouldn't be too hard, should it?
```

*seems* simple but there must be more to it
```sh
> for x in {1..100} ; do touch file$x ; done
> ga .
> gc -m '100 files'
You're trying to add too many files at once! I only allow one file at a time, but you are trying to add 101!
```
let's check what the pre-commit hook is doing
```sh
> cat githooks/pre-commit
#!/bin/sh
how_many_new_files=$(git status -s | grep '^A' | grep add_files_here | wc -l) 

if [ $how_many_new_files -ne 1 ]; 
then
    echo "You're trying to add too many files at once! I only allow one file at a time, but you are trying to add "$how_many_new_files"!"
    exit 1
fi
```
let's just make this true
```txt
...
if [ true ];
```
and attempt again
```sh
> gc -m '100'
> git push
remote: You won! The flags are
remote: cyprus-akees-metope (hooks-2)
remote: geared-tidal-consolidated (remote-1)
```
flags = `cyprus-akees-metope` & `geared-tidal-consolidated`

### hooks-2
```sh
> cat README.md
**For this stage, you must run the script setup_hooks_stage.sh first!**

Try to commit something.

Note: Make sure you undo what the previous stage did! If you're unsure what it did, go back and make sure you do understand it.
```
let's check to make sure that the previous pre-commit hook doesn't do anything
```sh
> file .git/hooks/pre-commit
.git/hooks/pre-commit: broken symbolic link to ../../githooks/pre-commit
```
will need to remove that broken symlink
```sh
> rm .git/hooks/pre-commit
```
now let's try and commit something
```sh
> gc -m 'try' --allow-empty
Commit message: try
Write 'git is awesome' in your commit message
```
need a specific commit message
```sh
> gc -m 'git is awesome' --allow-empty
> gc -m 'git is awesome' --allow-empty
Commit message: git is awesome
I agree; git is awesome!
[cyprus-akees-metope aec100c] git is awesome
> git push
remote: You won! The flag is hooks-levels-done-you-win (final)
```
flag = `geared-tidal-consolidated`

hooks are cool I guess

## remote
### remote-1
```sh
> cat README.md
To pass this stage you'll need a file with the correct password. This work has ALREADY been pushed to a different fork of this repository, which you'll find at 

gamemaster@localhost:~/forked-ctf-repo

You'll have to merge changes from the same branch on the remote.

Note: no need to edit files in this stage, only git commands will suffice.
```
I'm thinking to add a new remote that points at the specified fork, merge changes from that remote, and push

```sh
> git remote add fork gamemaster@localhost:~/forked-ctf-repo
> git fetch fork geared-tidal-consolidated
> git merge fork/geared-tidal-consolidated
```

nailed it
```sh
> git push
remote: You won! The flag is main-levels-done-you-win (final)
```
flag = `main-levels-done-you-win`

## conclusion
that was fun, probably took a couple hours over a couple days to get through everything

