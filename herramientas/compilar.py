"""Compila V2 y sus pruebas solo con símbolos Microsoft, sin publicar."""
import json, os, shutil, subprocess, tempfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'app.json').read_text())
if manifest.get('dependencies'):
    raise SystemExit('La extensión independiente no debe declarar dependencias de terceros.')
extensiones = sorted((Path.home() / '.vscode/extensions').glob('ms-dynamics-smb.al-*'), key=lambda p: tuple(int(n) for n in __import__('re').findall(r'\d+', p.name)))
compiler_root = Path(os.environ['AL_EXTENSION']) if os.environ.get('AL_EXTENSION') else (extensiones[-1] if extensiones else None)
if compiler_root is None or not (compiler_root / 'bin/alc.dll').is_file():
    raise SystemExit('Instale la extensión AL de VS Code o indique su carpeta mediante AL_EXTENSION.')
runtimes = Path.home() / 'Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet'
candidatos = sorted(runtimes.glob('10.*~arm64~aspnetcore/dotnet'))
dotnet = os.environ.get('AL_DOTNET') or (str(candidatos[-1]) if candidatos else None) or shutil.which('dotnet')
if not dotnet:
    raise SystemExit('Indique el ejecutable .NET mediante AL_DOTNET o instale el runtime requerido por AL.')
if not list((root / '.alpackages').glob('Microsoft_*.app')):
    raise SystemExit('Descargue los símbolos Microsoft en .alpackages desde VS Code antes de compilar.')
artifacts = root / 'artefactos'
artifacts.mkdir(exist_ok=True)

def compile(project, output, cache):
    subprocess.run([
        dotnet, str(compiler_root / 'bin/alc.dll'), f'/project:{project}',
        f'/packagecachepath:{cache}', f'/out:{output}',
        '/errorlog:' + str(artifacts / (output.stem + '.diagnostics.json')),
        '/generatereportlayout-',
    ], check=True, cwd=root)

with tempfile.TemporaryDirectory(prefix='hn-independent-build-') as temporary:
    staging = Path(temporary)
    cache = staging / 'microsoft-symbols'
    cache.mkdir()
    for package in (root / '.alpackages').glob('Microsoft_*.app'):
        shutil.copy2(package, cache / package.name)
    output = artifacts / f'INVTECH_LocalizacionHN_V2_{manifest["version"]}.app'
    compile(root, output, cache)
    # El proyecto de pruebas recibe los símbolos V2 mediante una caché aislada.
    shutil.copy2(output, cache / output.name)
    tests = staging / 'pruebas'
    tests.mkdir()
    test_manifest = {
        'id': '0c2e0e07-0214-4e2c-b613-a04927845306',
        'name': 'LocalizacionHN_V2 Pruebas', 'publisher': 'INVTECH',
        'version': manifest['version'], 'platform': manifest['platform'],
        'application': manifest['application'], 'runtime': manifest['runtime'],
        'idRanges': [{'from': 71250, 'to': 71299}],
        'dependencies': [{key: manifest[key] for key in ['id', 'name', 'publisher', 'version']}],
        'features': ['NoImplicitWith'],
    }
    (tests / 'app.json').write_text(json.dumps(test_manifest, indent=2) + '\n')
    shutil.copy2(root / 'pruebas/PruebasNucleo.template', tests / 'HNCoreTests.al')
    compile(tests, artifacts / f'INVTECH_LocalizacionHN_V2_Pruebas_{manifest["version"]}.app', cache)
print('V2 y pruebas compilados sin símbolos de Localizacion_HN ni de terceros.')
print('Las pruebas AL deben ejecutarse en un sandbox de Business Central.')
