/* The only file in the stub that imports three.js.

   The split is load-bearing, not tidiness. vite.config.js puts three in its own chunk and
   bundle-budget.json watches that chunk at a 1% tolerance, so a `import { Vector3 } from
   'three'` that wanders into src/sim shows up as the game chunk growing by a hundred
   kilobytes. The pure layer may `import type` from three and nothing else. */

import {
  AmbientLight, BoxGeometry, DirectionalLight, Mesh, MeshStandardMaterial,
  PerspectiveCamera, Scene, WebGLRenderer
} from 'three';
import type { World } from '../sim/state';

export interface View {
  render(w: World): void;
  resize(): void;
  readonly canvas: HTMLCanvasElement;
}

export function makeView(host: HTMLElement): View {
  const renderer = new WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
  /* Cap the device pixel ratio. A modern phone reports 3 and a fragment shader then runs
     nine times per CSS pixel, which is the single easiest way to make a game thermally
     throttle in the first two minutes. */
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  host.appendChild(renderer.domElement);

  const scene = new Scene();
  const camera = new PerspectiveCamera(50, 1, 0.1, 100);
  camera.position.set(0, 1.2, 4);
  camera.lookAt(0, 0, 0);

  scene.add(new AmbientLight(0x223355, 2.2));
  const key = new DirectionalLight(0xcfe3ff, 2.6);
  key.position.set(2, 3, 2);
  scene.add(key);

  const mesh = new Mesh(
    new BoxGeometry(1.4, 1.4, 1.4),
    new MeshStandardMaterial({ color: 0x4f7fbf, roughness: 0.45, metalness: 0.1 })
  );
  scene.add(mesh);

  function resize() {
    const w = host.clientWidth || window.innerWidth;
    const h = host.clientHeight || window.innerHeight;
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  resize();

  return {
    canvas: renderer.domElement,
    resize,
    render(w: World) {
      mesh.rotation.y = w.spin;
      mesh.rotation.x = w.spin * 0.5;
      renderer.render(scene, camera);
    }
  };
}
