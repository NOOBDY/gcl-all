import renderSection from "../Section";

export default function renderGlobalProp(
  globalProp: string
): string {
  return renderSection("Global Property", globalProp)
}
