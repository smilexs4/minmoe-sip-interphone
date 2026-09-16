# minmoe-sip-interphone

## Why this project is shelved

The original goal was to use this as a real interphone replacement — able to
receive a call from the door terminal on a phone.
On iOS, that requires the SIP app (Zoiper, etc.) to wake up from the
background via Apple's push notification service, which the app vendors only
offer as a paid add-on. I didn't want to pay for that subscription, so the
project stops at "works reliably when the phone app is open and on the same
network" rather than "works like a real doorbell." If you don't care about
iOS background calling (e.g. Android, or a phone that stays on this network
and awake), this setup works fine and there's no reason not to continue it.

## What this is

Docker + Asterisk (PJSIP) bridging a **Hikvision Minmoe door station**
(model `DS-K1T342MFWX-E1`, firmware `V4.39.180 build 250912`) and a regular
SIP softphone (MicroSIP / Zoiper), as a DIY interphone:

- **1001** = softphone
- **1002** = Minmoe terminal

## Confirmed working, on real hardware

- Audio only calls bridge cleanly in both directions once both sides are registered.
- Pressing **`#`** during a call passes through Asterisk untouched (RFC4733)
  and reaches the Minmoe, which opens the door via its own configured
  in-call DTMF unlock code.
- Pressing **`*`** is caught by Asterisk as a call feature instead of being
  forwarded, and fires an HTTP ISAPI request straight at the Minmoe
  (`scripts/open_door.sh`) — a working fallback that opens the door even if
  in-band DTMF isn't cooperating.

## The one gotcha that isn't obvious from Asterisk's side

Registering the Minmoe as a SIP account is not enough for it to place
*outbound* calls. You also need, on the terminal itself:

**Video Intercom → Number Settings → add an entry pairing a room number with
the SIP number you want it to call.**

Without this, the Minmoe registers and can *receive* calls fine, but silently
never sends an INVITE when you try to call out from it — no error, it just
doesn't dial. This cost real debugging time because Asterisk's logs showed
nothing wrong (because nothing ever reached Asterisk).

## Other things worth knowing

- SIP passwords in `asterisk-config/pjsip.conf` are still the placeholders
  (`CHANGE_ME_1001` / `CHANGE_ME_1002`) unless you changed them — whatever
  you actually typed into your devices is the real password now.
- `docker-compose.yml` uses `network_mode: host`, so this only runs on Linux
  (fine for a Pi; won't work as-is on Docker Desktop for Mac/Windows).
- LAN-only, no TLS/SRTP. Don't expose UDP/5060 or the RTP range to the
  internet without adding both.
- `.env` holds the Minmoe's admin credentials for the ISAPI door call.
- Rebuild/redeploy with `docker compose up -d --build`; check state with
  `docker exec -it aer-asterisk asterisk -rx "pjsip show endpoints"`.
