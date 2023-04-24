import { Suspense, useRef, useState, useEffect } from "react";
import { TransformControls } from "@react-three/drei";
import { useNuiEvent, fetchNui } from "../nui-events";
import { Mesh, MathUtils } from "three";

export const TransformComponent = () => {
  const mesh = useRef<Mesh>(null!);
  const [currentEntity, setCurrentEntity] = useState<number>();
  const [editorMode, setEditorMode] = useState<
    "translate" | "rotate" | undefined
  >("translate");

  const handleObjectDataUpdate = () => {
    const entity = {
      handle: currentEntity,
      position: {
        x: mesh.current.position.x,
        y: -mesh.current.position.z,
        z: mesh.current.position.y,
      },
      rotation: {
        x: MathUtils.radToDeg(mesh.current.rotation.x),
        y: MathUtils.radToDeg(-mesh.current.rotation.z),
        z: MathUtils.radToDeg(mesh.current.rotation.y),
      },
    };
    fetchNui("moveEntity", entity);
  };

  useNuiEvent("setGizmoEntity", (entity: any) => {
    setCurrentEntity(entity.handle);
    if (!entity.handle) {
      return;
    }

    mesh.current.position.set(
      entity.position.x,
      entity.position.z,
      -entity.position.y
    );
    mesh.current.rotation.order = "YZX";
    mesh.current.rotation.set(
      MathUtils.degToRad(entity.rotation.x),
      MathUtils.degToRad(entity.rotation.z),
      MathUtils.degToRad(entity.rotation.y)
    );
  });

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      switch (e.code) {
        case "KeyR":
          setEditorMode("rotate");
          break;
        case "KeyW":
          setEditorMode("translate");
          break;
        case "Escape":
          fetchNui("finishEdit");
          break;
        default:
          break;
      }
    };
    window.addEventListener("keyup", keyHandler);
    return () => window.removeEventListener("keyup", keyHandler);
  });

  return (
    <>
      <Suspense fallback={<p>Loading Gizmo</p>}>
        {currentEntity != null && (
          <TransformControls
            size={0.5}
            object={mesh}
            mode={editorMode}
            onObjectChange={handleObjectDataUpdate}
          />
        )}
        <mesh ref={mesh} />
      </Suspense>
    </>
  );
};
