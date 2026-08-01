# 07 — Dental Chart

## Purpose

Digitize the PDA paper dental chart (spec §9): adult + primary dentition, per-surface marking, color coding, and full historical records. Wizard step 6. The most complex module in the system.

## Design Decisions

1. **FDI tooth numbering** (ISO 3950) — adult quadrants 1–4 (teeth 11–48), primary quadrants 5–8 (teeth 51–85). Default choice; see Q1.
2. **Append-only event log**: every chart edit inserts a new `dental_chart_entries` row. The rendered chart = latest row per (tooth, surface). History view = all rows grouped by date. This gives the *historical records* requirement plus a complete audit trail at zero extra cost.
3. **Whole-tooth vs surface marks**: a condition can apply to the whole tooth (`surface = null`) or a specific surface (mesial/occlusal/buccal/lingual/distal). Rendering overlays per surface on the tooth shape.
4. **Color coding** driven by the `ToothCondition` enum `meta('color')` → Tailwind token (see 02-tech-stack.md).

## Database — `dental_chart_entries`

```php
// 2026_01_01_000007_create_dental_chart_entries_table.php
Schema::create('dental_chart_entries', function (Blueprint $table) {
    $table->id();
    $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
    $table->unsignedTinyInteger('tooth_number');               // FDI: adult 11–48, primary 51–85
    $table->string('dentition')->default('adult');             // DentitionType enum
    $table->string('condition');                               // ToothCondition enum
    $table->string('surface')->nullable();                     // ToothSurface enum; null = whole tooth
    $table->string('color_code', 32)->nullable();              // denorm snapshot of condition color (rendering stability)
    $table->text('notes')->nullable();
    $table->date('recorded_at');                               // clinical date (may differ from created_at)
    $table->foreignId('recorded_by')->constrained('users')->cascadeOnDelete();
    $table->timestamps();

    $table->index(['patient_id', 'tooth_number', 'surface', 'recorded_at']);
});
```

No update/delete endpoints — entries are immutable. Corrections = new entry (same tooth/surface) which supersedes by recency.

## Enums

```php
enum DentitionType: string
{
    case Adult   = 'adult';
    case Primary = 'primary';

    // meta(): label ('Adult', 'Primary'), teethRange [11,48] / [51,85]
}

enum ToothCondition: string
{
    case Caries      = 'caries';      // red
    case Filling     = 'filling';     // blue
    case Missing     = 'missing';     // neutral gray
    case RootCanal   = 'root_canal';  // blue center dot
    case Crown       = 'crown';       // violet outline
    case Fracture    = 'fracture';    // orange zigzag
    case Impacted    = 'impacted';    // amber, un-erupted
    case Pontic      = 'pontic';      // teal bridge tooth
    // meta(): label, color token, fill mode (solid/outline/dot/zigzag), toggleable (missing/pontic are whole-tooth only)
}

enum ToothSurface: string
{
    case Occlusal = 'occlusal';
    case Buccal   = 'buccal';
    case Lingual  = 'lingual';
    case Mesial   = 'mesial';
    case Distal   = 'distal';
    // meta(): label, position on tooth SVG (top/left/right/bottom)
}
```

## Model + Chart Projection (Service)

```php
class DentalChartEntry extends Model
{
    use HasActivity;

    protected $guarded = [];
    protected function casts(): array
    {
        return [
            'dentition'   => DentitionType::class,
            'condition'   => ToothCondition::class,
            'surface'     => ToothSurface::class,
            'recorded_at' => 'date',
        ];
    }
}
```

```php
final class DentalChartService
{
    /**
     * Latest state per (tooth, surface) — the rendered chart.
     * Returns array keyed by tooth_number → ['whole' => Condition?, 'surfaces' => [surface => Condition]]
     */
    public function currentState(int $patientId, DentitionType $dentition): array
    {
        return DentalChartEntry::where('patient_id', $patientId)
            ->where('dentition', $dentition->value)
            ->orderBy('recorded_at')
            ->orderBy('id')
            ->get()
            ->groupBy('tooth_number')
            ->map(fn ($rows) => $this->projectLatestPerSurface($rows))
            ->toArray();
    }

    /** Full historical log for a tooth or date range */
    public function history(int $patientId, ?int $toothNumber = null, ?Carbon $from = null): Collection { ... }

    /** Snapshot an entry (currentState for one tooth) for chart restoration */
    public function snapshot(int $patientId): array { ... }
}
```

`RecordToothConditionAction::handle(patient, tooth, dentition, condition, surface, recordedAt, dentist)` — validates FDI range, inserts immutable row, logs activity `chart.updated`.

## State Machine

None — the chart is an append-only log, not a stateful entity. The only "transition" is supersession by recency (newest entry wins).

## Permissions

| Permission | Roles |
|---|---|
| `dental-chart.view` | administrator, dentist, assistant |
| `dental-chart.update` | administrator, dentist |

## UI Elements (improvised — no Figma)

- **ToothChart component** (`resources/js/Components/ToothChart.vue`): SVG twin-arch diagram — upper arch (11–18 / 51–55), lower arch (41–48 / 71–75), mirrored patient's-right/left. Tooth shape with 5 clickable surface zones (O/B/L/M/D) + whole-tooth click.
- **Condition palette** (`ToothLegend`): 8 color chips (condition → OKLCH token), selected condition highlights; tap tooth/surface applies.
- **Dentition toggle**: Adult / Primary segmented control; chart switches tooth set.
- **History drawer**: date slider or list; selecting a past date renders the chart state **as of that date** (entries with `recorded_at ≤ date`).
- **Color coding legend** always visible on chart screen.

## Rendering Rules (improvised defaults)

| Condition | Whole tooth | Surface | Render |
|---|---|---|---|
| Caries | ✓ | ✓ | solid red fill (surface zone) |
| Filling | ✓ | ✓ | solid blue fill |
| Missing | ✓ | ✗ | gray tooth with X (hidden in chart count) |
| Root canal | ✓ | ✗ | blue dot at center |
| Crown | ✓ | ✗ | violet outline ring |
| Fracture | ✓ | ✓ | orange zigzag line across zone |
| Impacted | ✓ | ✗ | amber tooth, dashed outline |
| Pontic | ✓ | ✗ | teal tooth, lighter fill |
