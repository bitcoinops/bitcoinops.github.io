---
permalink: /en/tools/reorg-calculator/
title: "Reorg Calculator"
layout: page
breadcrumbs: false
---


<form action="" id="hashcalc_kappa" onsubmit="return false;">
  <fieldset>
    Attacker's hash power (%): <input type="number" id="hashpower" min="0" max="100" value="24" onchange="updateProbability()"/><br>
    Blocks to catch up: <input type="number" id="blocks" min="0" value="6" onchange="updateProbability()"/><br>
    Time ratio (κ): <input type="number" step="0.0001" id="kappa" min="0.0" value="1.0" onchange="updateProbability()"/>

    <br><br><hr>
    <div id="result"></div>
  </fieldset>
</form>

<script>
/**
 * Q(z, x) = Upper Regularized Incomplete Gamma (integer z>0):
 *           Q(z,x) = e^(-x) * sum_{n=0}^{z-1} [x^n / n!].
 */
function upperGammaQ(z, x) {
  if (z <= 0) return 1.0;
  if (x < 0)  return 1.0;

  let sum = 0.0;
  let term = 1.0; // x^0 / 0!
  for (let n = 0; n < z; n++) {
    if (n > 0) term *= x / n;
    sum += term;
  }
  return Math.exp(-x) * sum;
}

/**
 * attackerSuccessProbabilityKappa(q, z, kappa)
 *
 * Conditional double-spend probability from "Double Spend Races".
 *
 * P(z, kappa) = 1
 *   - Q(z, kappa*z*(q/p))
 *   + (q/p)^z * exp[kappa*z*((p-q)/p)] * Q(z, kappa*z)
 */
function attackerSuccessProbabilityKappa(q, z, kappa) {
  if (q >= 0.5) {
    return 1.0; // >=50% hash => indefinite success
  }
  const p = 1.0 - q;

  const alpha = kappa * z * (q/p);
  const beta  = kappa * z;

  const term1 = 1.0 - upperGammaQ(z, alpha);
  const term2 = Math.pow(q/p, z)
    * Math.exp(kappa * z * ((p-q)/p))
    * upperGammaQ(z, beta);

  return term1 + term2;
}

function updateProbability() {
  const q      = parseFloat(document.getElementById("hashpower").value || "0") / 100.0;
  const z      = parseInt(document.getElementById("blocks").value || "0", 10);
  const kappa  = parseFloat(document.getElementById("kappa").value || "1");

  const prob   = attackerSuccessProbabilityKappa(q, z, kappa);
  const pct    = (prob * 100).toFixed(7);

  document.getElementById("result").innerHTML = (
    "<b>Attack success probability:</b> " + pct + "%<br><br>"
    + "<table>"
    + "<tr><th>Parameter</th><th>Value</th></tr>"
    + "<tr><td>Attacker hashrate (q)</td><td>" + (q*100).toFixed(3) + "%</td></tr>"
    + "<tr><td>Honest hashrate (p)</td><td>" + ((1-q)*100).toFixed(3) + "%</td></tr>"
    + "<tr><td>Blocks behind (z)</td><td>" + z + "</td></tr>"
    + "<tr><td>Kappa (κ)</td><td>" + kappa.toFixed(4) + "</td></tr>"
    + "</table>"
  );
}

// Initialize on page load
updateProbability();

// Tests
function runTests() {
    const EPSILON = 1e-10;  // Very small number for floating-point comparisons
    console.log("Running reorg calculator tests...");

    // 1) q=0 => 0% success, regardless of z,kappa
  {
    const prob = attackerSuccessProbabilityKappa(0, 5, 1);
    console.assert(Math.abs(prob) < EPSILON,
      "Test #1 fail: q=0 => expect 0, got " + prob);
  }

  // 2) q=0.5 => always 100% success
  {
    const prob = attackerSuccessProbabilityKappa(0.5, 5, 2);
    console.assert(Math.abs(prob - 1) < EPSILON,
      "Test #2 fail: q=0.5 => expect 1, got " + prob);
  }

  // 3) Larger kappa => typically bigger success probability (same q,z)
  {
    const pLow = attackerSuccessProbabilityKappa(0.3, 5, 0.5); // smaller kappa
    const pHigh = attackerSuccessProbabilityKappa(0.3, 5, 2.0); // bigger kappa
    console.assert(pHigh >= pLow,
      "Test #3 fail: kappa=2 => prob should be >= kappa=0.5. pLow=" + pLow + ", pHigh=" + pHigh);
  }

  // 4) More blocks => smaller probability (assuming kappa=1)
  {
    const p1Block = attackerSuccessProbabilityKappa(0.3, 1, 1);
    const p10Blocks = attackerSuccessProbabilityKappa(0.3, 10, 1);
    console.assert(p1Block > p10Blocks,
      "Test #4 fail: prob should decrease with more blocks. p1Block=" + p1Block + ", p10Blocks=" + p10Blocks);
  }

  console.log("All conditional (kappa) tests passed!");
  return true;
}
</script>

<br/> <br/>
This calculator shows the probability that an attacker with a given percentage of the total network hashrate could successfully reorganize `z` blocks, based on the *conditional* formula in [Double Spend Races] which includes **κ** (time ratio).



### Parameters:

- **Attacker hashrate (% q)**: The portion of total network hashrate controlled by the attacker
- **Honest hashrate (% p)**: The portion controlled by honest miners (1 - q)
- **Blocks behind (z):** How many blocks the honest chain is ahead.
- **Time ratio (κ):**
  - If `κ > 1`, honest blocks took *longer* than average ⇒ attacker has higher chance.
  - If `κ < 1`, honest blocks were *faster* ⇒ lower attacker chance.
  - If `κ=1`, you ignore timing and assume an "average" scenario (Satoshi's formula).


{% include references.md %}
[Double Spend Races]: https://diyhpl.us/~bryan/papers2/bitcoin/Double%20spend%20races%20-%202017.pdf