---
title: 'Bitcoin Optech Newsletter #87'
permalink: /en/newsletters/2020/03/04/
name: 2020-03-04-newsletter
slug: 2020-03-04-newsletter
type: newsletter
layout: newsletter
lang: en
---

## Action items

## News

## Highlights from the Bitcoin Core PR Review Club

The [Bitcoin Core PR Review Club][] is a weekly IRC meeting for newer
contributors to the Bitcoin Core project to learn about the review process. An
experienced Bitcoin Core contributor provides background information about a
selected PR and then leads a discussion on IRC.

The Review Club is an excellent way to learn about the Bitcoin protocol, the
Bitcoin Core reference implementation, and the process of making changes to
Bitcoin. Notes, questions and meeting logs are posted on the website for those
who are unable to attend in real time, and as a permanent resource for those
wishing to learn about the Bitcoin Core development process.

In this section, we summarise some recent Review Club meetings.

- **[O(1) OP_IF/NOTIF/ELSE/ENDIF script implementation / Abstract out script execution out of VerifyWitnessProgram()][review club 16902]:**
  These PRs ([#16902][Bitcoin Core #16902] and [#18002][Bitcoin Core #18002]) are
  both small refactors that have been pulled out of the [Schnorr/Taproot
  implementation PR][Bitcoin Core #17977]. The author explains in PR 18002:
  "[this] simplifies the changes for Taproot significantly [...] I may as well
  give it some additional attention by PRing it independently."

    Both PRs make changes to Bitcoin Core's script interpreter code -- a
    section of the codebase which is very seldom changed by developers. Discussion
    in the meeting covered the use of asserts and logging in Bitcoin Core, performance
    and benchmarking, and how to test and review changes to consensus-critical
    code.

[Bitcoin Core PR Review Club]: https://bitcoincore.reviews

## Notable code and documentation changes

{% include references.md %}
{% include linkers/issues.md issues="16902,17977,18002" %}
[review club 16902]: https://bitcoincore.reviews/16902
