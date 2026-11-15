"""Auditoría OFFLINE de V13: sintaxis superficial, contenido y fuentes; NO ejecuta Godot."""
from pathlib import Path
import re,json,csv,math
root=Path(__file__).resolve().parents[1]
scenes=list((root/'scenes').glob('*.tscn'))
scripts=list((root/'scripts').glob('*.gd'))
assert len(scenes)==14,(len(scenes),'scenes')
assert len(scripts)==27,(len(scripts),'scripts')
assert (root/'scenes/numeric_lab.tscn').exists()
assert (root/'scripts/planetary_facts.gd').exists()
assert (root/'scripts/orbital_view.gd').exists()
for f in (root/'data').glob('*.json'):
    assert json.loads(f.read_text(encoding='utf-8')),f
refs=[]
for f in scenes+scripts:
    content=f.read_text(encoding='utf-8')
    for rel in re.findall(r'res://([A-Za-z0-9_./-]+\.(?:gd|tscn|wav|jpg|png|json|csv))',content):
        refs.append(rel)
        assert (root/rel).is_file(),(f,rel)
    # Balanced delimiters outside quoted GDScript strings and comments, not full parsing.
    delimiters=[]; pair={'(':')','[':']','{':'}'}; quote=False; escaped=False
    for line in content.splitlines():
        for char in line:
            if quote:
                if escaped: escaped=False
                elif char=='\\': escaped=True
                elif char=='"': quote=False
            elif char=='#': break
            elif char=='"': quote=True
            elif char in pair: delimiters.append(pair[char])
            elif char in ')]}':
                assert delimiters and delimiters.pop()==char,(f,char)
    assert not quote and not delimiters,f

with (root/'data/nasa_planetary_facts.csv').open(encoding='utf-8') as fp:
    records={r['body']:r for r in csv.DictReader(fp)}
assert set(records)=={'TIERRA','LUNA','VENUS','MARTE'}
for k,x in {'TIERRA':9.8,'LUNA':1.6,'VENUS':8.9,'MARTE':3.7}.items():
    assert math.isclose(float(records[k]['gravity_m_s2']),x)
for k,x in {'TIERRA':11.2,'LUNA':2.4,'VENUS':10.4,'MARTE':5.0}.items():
    assert math.isclose(float(records[k]['escape_km_s']),x)
for k,x in {'TIERRA':1361.0,'LUNA':1361.0,'VENUS':2601.3,'MARTE':586.2}.items():
    assert math.isclose(float(records[k]['irradiance_w_m2']),x)
assert all(float(r['diameter_km'])>1000 for r in records.values())
physics=(root/'scripts/simulation.gd').read_text(encoding='utf-8')
assert 'out["fuel"] = float(out["fuel"]) +' not in physics,'Potential fuel creation'
assert 'delta_v_used_mps' in physics and 'last_burn_delta_v_mps' in physics
assert 'science_review' in physics and 'dataset_points' in physics
assert 'float(overall)*0.80' in physics
flow=(root/'scripts/science_analysis.gd').read_text(encoding='utf-8')
assert 'res://scenes/numeric_lab.tscn' in flow
save=(root/'scripts/game_data.gd').read_text(encoding='utf-8')
assert 'mission_unknown_v13_save' in save and 'LEGACY_SAVE_PATH' in save
assert 'register_dataset_choice' in save
assert (root/'docs/FUENTES_NASA_V13.md').exists()
print(f'PASS V13 STATIC: {len(scenes)} scenes, {len(scripts)} scripts, {len(refs)} valid resource references, NASA table 4 bodies, navigation and score rules present. NOT a Godot execution test.')
