Informative and efficient git prompt for zsh
==============================

A ``zsh`` prompt that displays information about the current git repository.
In particular the branch name, difference with remote branch, number of files staged, changed, etc.

This fork was motivated by the sluggishness of the git prompt from
`zsh-git-prompt`_, despite a prototype cache system. Getting the git
status via python was still retained as the preferred way as it is
much neater than the vcs_info alternative.

Examples
--------

The prompt may look like the following: 

* ``(master↑3|✚1)``: on branch ``master``, ahead of remote by 3 commits, 1 file changed but not staged
* ``(status|●2)``: on branch ``status``, 2 files staged
* ``(master|✚7⚡…)``: on branch ``master``, 7 files changed, some files untracked
* ``(master|✖2✚3)``: on branch ``master``, 2 conflicts, 3 files changed
* ``(experimental↓2↑3|✔)``: on branch ``experimental``; your branch has diverged by 3 commits, remote by 2 commits; the repository is otherwise clean
* ``(:70c2952|✔)``: not on any branch; parent commit has hash ``70c2952``; the repository is otherwise clean

Here is how it could look like when you are ahead by 4 commits, behind by 5 commits, and have 1 staged files, 1 changed but unstaged file, and some untracked files, on branch ``dev``:

.. image:: https://github.com/olivierverdier/zsh-git-prompt/raw/master/screenshot.png
	:alt: Example

.. _zsh_git-prompt: https://github.com/olivierverdier/zsh-git-prompt

Prompt structure
----------------

By default, the general appearance of the prompt is::

    (<branch><branch tracking>|<local status>)

The symbols are as follows:

* Local Status Symbols
	:✔: repository clean
	:●n: there are ``n`` staged files
	:✖n: there are ``n`` unmerged files
	:✚n: there are ``n`` changed but *unstaged* files
	:⚡…: there are some untracked files

* Branch Tracking Symbols
	:↑n: ahead of remote by ``n`` commits
	:↓n: behind remote by ``n`` commits
	:↓m↑n: branches diverged, other by ``m`` commits, yours by ``n`` commits

* Branch Symbols
	When the branch name starts with a colon ``:``, it means it's actually a hash, not a branch (although it should be pretty clear, unless you name your branches like hashes :-)

Install
-------

#. Create the directory ``~/.zsh/git-prompt-python`` if it does not exist (this location is customizable).
#. Move the file ``gitstatus.py`` into ``~/.zsh/git-prompt-python/``.
#. After configuring your prompt in ``git-prompt-python.zsh``, source
the file ``git-prompt-python.zsh`` from your ``~/.zshrc`` config
file. So, somewhere in ``~/.zshrc``, you should have::
        
	source path/to/git-prompt-python.zsh
	
Alternatively, you could also configure directly your prompt in
``~/.zshrc`` (remove the definition in ``git-prompt-python.zsh``)::

	# an example prompt
	PROMPT='%B%m%~%b$(git_super_status) %# '

#. You may also redefine the function ``git_super_status`` to adapt it
 to your needs (to change the order in which the information is
 displayed). You may also change a number of variables (the name of
 which start with ``ZSH_THEME_GIT_PROMPT_``) to change the appearance
 of the prompt. Take a look in the file ``git-prompt-python.zsh`` to
 see how the function ``git_super_status`` is defined, and what
 variables are available.
#. Go in a git repository and test it!

**Enjoy!**
