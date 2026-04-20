export default function PlayPage() {
  return (
    <div className="flex flex-col" style={{ height: "calc(100vh - 57px)" }}>
      <iframe
        src="/game/CodingGamePrototype.html"
        className="flex-1 w-full border-0"
        allow="autoplay; fullscreen"
        title="LediBug Game"
      />
    </div>
  );
}
