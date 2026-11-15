"""Independent numerical and data validation. Not a Godot run."""
from pathlib import Path
import csv,math,subprocess,sys
root=Path(__file__).resolve().parents[1]
rows={r['body']:r for r in csv.DictReader((root/'data/nasa_planetary_facts.csv').open(encoding='utf-8'))}
e=rows['TIERRA']
for body in ['LUNA','VENUS','MARTE']:
    r=rows[body]
    g=float(r['gravity_m_s2']);v=float(r['escape_km_s']);f=float(r['irradiance_w_m2'])
    weight=10.0*g
    escape_pct=round(v/float(e['escape_km_s'])*100)
    flux_pct=round(f/float(e['irradiance_w_m2'])*100)
    assert 0<weight<110 and 0<escape_pct<=100 and 0<flux_pct<220
    print(f'{body}: 10 kg weight {weight:.1f} N; escape {escape_pct}% Earth; solar flux {flux_pct}% Earth')
# Rocket equation: diminishing remaining propellant means diminishing available delta-v.
def delta_v(dry,p): return 320.0*9.80665*math.log((dry+p)/dry) if dry>0 and p>0 else 0.0
for dry,fuel in [(92,98),(112,67),(136,64)]:
    capacities=[delta_v(dry,2*max(fuel-n,0)) for n in [0,5,15,35,100]]
    assert capacities==sorted(capacities,reverse=True)
    used=capacities[0]-capacities[1]
    assert used>0
print('PASS Δv monotonic and nonnegative across 3 hypothetical spacecraft configurations')
# Existing independent V12 mirror remains a regression guide for victory/loss routes;
# its Python translation is not Godot engine and does not include every V13 change.
p=subprocess.run([sys.executable,str(root/'tests/validacion_matematica.py')],capture_output=True,text=True)
assert p.returncode==0,(p.stdout,p.stderr)
assert 'VALIDATION V11 PASSED' in p.stdout
print('PASS prior mirror regression: 3 playable configurations, wins and losses; V13 Godot simulation still requires engine-run test')
