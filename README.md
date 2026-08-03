# Astroventures

Roblox game about scouting planets for a dying Earth to resettle on, split across a hub world and a planet world. Unreleased, built April 2024 to June 2025. Team of two: I designed and scripted it and built some models; my collaborator built the rest.

## What it is

Earth is dying, and the player works for a company scanning and shortlisting planets humans could resettle on. Difficulty rises with each planet cleared, and dying sends the player back to the start with nothing carried over.

## Terrain that didn't finish loading in time

The planet's terrain doesn't finish streaming in before the player's character spawns. In testing that meant falling through the world with no floor loaded, or landing into a blank scene mid-animation. The fix raycasts from the terrain's corners and marks it loaded once every ray hits ground. A separate check comparing client and server cell counts also exists; the raycast version is what actually fixed the bug.

## Building for multiplayer that never arrived

Moving from the hub to a planet reserves a private server for that player instead of a shared public one. That was deliberate: multiplayer was planned for later, and reserved servers from the start meant a later move to shared ones wouldn't mean reworking teleportation. Multiplayer never got built, so each server still only holds one player.

## Two different rules for where new code goes

The hub and the planet world use different conventions for adding systems. In the hub, each system is a standalone script requiring a matching module by name, wired by hand. In the planet world, one entry script loops over every module beneath it and runs the same two-function pattern on each, load order set by tagging a module priority in Studio. A new planet-world system is just a module with those two functions; a new hub system means touching more than one file.

## Money was checked twice, cheating wasn't checked at all

The shop recalculates prices itself rather than trusting whatever number the client sends. Anti-cheat isn't handled the same way: it only listens for the client to report a violation and ask to be kicked, so detection and the kick decision both live on the player's machine. That gap exists because development stopped before exploit surfaces got real review, not because it was judged acceptable.

## Third-party code

ProfileService (Madwork's DataStore session-lock library) and CameraShaker (Stephen Leitnick's camera utility) are used as-is. A terrain save/load module, duplicated in two places, reads like a reused snippet by its header and shape, though it's uncredited. [CHECK]

## Status

Stopped mid-development in June 2025, after I lost interest in game dev. It never ran with live players, only in testing.
