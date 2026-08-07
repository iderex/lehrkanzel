# 0016 Headless and unelevated as a birth requirement

A suite that needs a display, a raised privilege, a firewall answer or a
container runtime is a suite that runs on one machine and is skipped everywhere
else. Written down afterwards it becomes a list of caveats in a contributing
guide. Written down now it is a property the tree refuses to lose.

This library has an easier time meeting that than most projects, and precisely
for that reason the rule is written while it is free. Nothing in a proof needs a
screen. What creeps in later is tooling: a documentation generator that wants a
browser, a graph renderer that wants a windowing library, a convenience script
that wants elevated rights to install something.

## The decision

Every step of a default run happens under all five of these constraints, on
Linux, on macOS and on Windows alike.

1. With no display attached. No step reads a display variable, launches a
   browser, or requires a windowing library to be present.
2. With no elevated privileges. No step invokes a privilege helper, and no step
   is documented as needing one. A step that would need one is a step that has
   been designed wrongly.
3. Without binding a listening socket.
4. Without reaching the network, once the dependencies are present.
5. Without writing outside the build directory and a temporary directory the run
   created itself.

Nothing in the default run is skipped for an environmental reason. A skip is how
a gap becomes invisible: a run that skipped a step reports the same green as a
run that executed it, and the difference is only in a log nobody opens.

## Why the listener is singled out

Binding a listening socket is named separately from the other four because of
what it costs rather than because it is more likely.

On Windows the first bind raises a firewall consent dialog. That dialog can only
be answered by an administrator, it interrupts whoever is at the machine, and
answering it settles nothing for the next build directory, so the interruption
repeats. A contributor who is not an administrator cannot answer it at all, and
for them the run does not fail cleanly, it hangs on a prompt.

Nothing in a proof library has any reason to open a port. The rule is therefore
free today, and the whole purpose of writing it down now is that it stays free.
The check is what keeps it free, not this file.

## Offline checking, online acquisition

The checking is offline. The acquisition is not.

Fetching the pinned toolchain, the pinned dependency and its prebuilt object
cache is a network step, and it happens before the run rather than inside it.
Once those are present, no step of the default run reaches the network.

The distinction is stated rather than blurred. A document that says the run
needs no network without the sentence about acquisition is overclaiming, and it
is the kind of overclaim that is discovered by somebody on an aeroplane with a
cold cache.

## Where an exempt path goes

One path genuinely cannot meet this, and it is the build of the dependency from
source with no prebuilt cache. It needs hours and several gigabytes of memory,
which is a machine rather than a CPU.

It is a separate harness with its own issue, #27. It is named for what it needs
rather than being called optional, and it does not gate. An exempt path that
gates is not an exception, it is the rule quietly withdrawn.

## Rejected

- Stating this in a contributing guide instead of a decision file. It is where
  such a rule usually lives and it is where it decays, because a guide is read
  once and a decision is cited.
- Allowing a step to be skipped where the environment cannot support it, and
  reporting the skip. It sounds more honest than failing, and it produces a green
  run that covered less than the reader believes. The rule this project already
  holds is that a run which covered less than the whole set cannot be readable as
  one that covered it.
- Requiring a container so that every run happens in a known environment. It
  makes the environment reproducible and it makes a container client a
  precondition of contributing, which is exactly the class of requirement this
  file exists to keep out.
- Writing the rule once the tooling exists. It is the ordinary order and it is
  the reason such rules are usually a list of caveats. The rule is cheapest to
  hold on the day nothing violates it.

## What it costs

Some tooling that would be convenient is refused. A documentation preview that
serves on a local port, a graph renderer that wants a windowing library, and an
installer script that elevates are all ruled out here rather than argued about
later, and a replacement for each has to be found or the feature dropped.

The acquisition step stays outside the guarantee, so a contributor on a cold
machine still needs a network and still waits. This file does not fix that and
does not claim to.

## What no check reads

Nothing refuses any of the five constraints today.

The check that would is the fourth rule of the table in issue #52, which is
open, and #26 is where the check and its proof are owed. Until one exists, this
file is carried by review, and the constraints are a property the tree happens
to have rather than one it cannot lose.

The three-platform claim in this file is a requirement placed on the default run
and not a measurement of one. There is no default run in this repository yet,
so nothing here has been observed on any of the three.
