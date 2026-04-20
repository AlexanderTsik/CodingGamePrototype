export default function PlayPage() {
  return (
    <div style={{ width: "100vw", height: "100vh", overflow: "hidden" }}>
      <iframe
        src="/game/CodingGamePrototype.html"
        style={{ width: "100%", height: "100%", border: "none", display: "block" }}
        allow="autoplay; fullscreen"
        title="LediBug Game"
      />
    </div>
  );
}
