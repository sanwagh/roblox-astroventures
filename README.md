# Astroventures

Roblox sci-fi mining/exploration game with a hub world and a separate planet world players teleport into. Unreleased. Built 2024-2025.

## What it is

Earth is nearly uninhabitable. Players work for a company sending them out to find planets humans can live on, starting from Earth and picking a save slot for their run. Before each trip the company sends requirements for the next planet, and on arrival the player uses tools to scan rocks, water, atmosphere, and air, checking the readings against those requirements to decide if the planet is worth shortlisting. Once five planets are shortlisted, the plan was for the player to travel again and run a second, more advanced round of checks to pick one, though those advanced checks were never designed in detail. Each planet also has its own resources to gather and alien life to deal with while the player is there, and requirements get harder as the player progresses through more planets. Between planets the player repairs and upgrades their ship to keep it from malfunctioning, and travels through wormholes and black holes to reach new galaxies, picking up information about each one along the way. Planets can reappear, and dying ends the run and sends the player back to the start. Progress, inventory, and mission status persist across sessions through DataStores.

## Architecture

The game is split into two Roblox places, `Lobby` and `Planet`, each with its own server and client script trees under `ServerScriptService` and `StarterPlayerScripts`. Lobby handles menus, the shop, save slot selection, doors, and the tutorial. Planet handles mining missions, terrain, and building.

Data persistence runs on ProfileService (MadWork's DataStore session-lock library, used as-is) wrapped by a custom `SlotLoader`. Each player gets a `SlotsDataStore` entry listing their save slots, and each slot maps to its own ProfileService profile keyed as `Data:<UserId><SlotId>`. This is how multiple save slots per player work on top of a library that normally assumes one profile per player.

Moving from Lobby to Planet goes through `TeleportService:ReserveServer`, not a plain place teleport. A reserved server means the player gets a private instance of the Planet place rather than landing on a shared public server.

The shop is server-authoritative: the client sends item names and quantities, and the server looks up prices from the item catalog and recomputes the total itself rather than trusting a client-sent price.

Mission state lives in two places at once: Roblox Instance Values parented to the player (for fast client reads) and the ProfileService profile (for persistence), kept in sync manually by the mission manager scripts.

Terrain loading is checked two different ways depending on which system needed it. `ClientTerrainCheck` polls a `CountCells` RemoteFunction and compares client cell count to server cell count until they match. `TerrainDetector` raycasts from parts placed at the corners of the terrain bounds and waits until every ray hits terrain within 1.5 studs. Both exist in the codebase; the raycast version was the fix for a real problem (below).

A few pieces are stubs with no logic: `PlacementEngine` (building placement) and `TeleportManager` are empty classes with `Init` functions that do nothing. `OLD_TabletClient_contents` sits next to the current `TabletClient_contents` from a UI rewrite that never got cleaned up.

CameraShaker (Stephen Leitnick's library) is used as-is for camera effects.

## Engineering notes

The reserved-server teleport model was a deliberate choice made early: the plan was to add multiplayer later, and building on reserved servers from the start meant that change wouldn't require reworking the teleport flow.

The biggest real bug during testing: the planet's terrain was large enough that it wouldn't finish loading before the player did. Players would either fall into the void if no floor block was in place yet, or spawn into a blank world during the landing animation, breaking the immersion. The fix was `TerrainDetector`, which raycasts from the top and bottom corners of the terrain volume and only signals "loaded" once every ray hits terrain. Everything else that came up in testing (a mission UI that occasionally didn't load correctly, etc.) was minor.

`AntiCheatEngine` only listens for the client to report a violation and ask the server to kick that player. Detection logic and the decision to kick both live on the client. Development stopped before exploit surfaces were seriously reviewed, so treat anything security-related in this codebase as unaudited.

Built with one other person. I designed the game, wrote all the scripting, and built some of the models. The other person built the remaining models.

## Status

Unreleased, stopped mid-development. Never ran with live players, only in testing. Worked on it from April 2024 to June 2025, then lost interest in game dev and moved on.
