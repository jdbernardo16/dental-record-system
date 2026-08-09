<?php

namespace App\Support;

use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;

/**
 * Shared helpers for dompdf exports.
 *
 * dompdf only renders SVG as <img> from a real file path, and rejects files
 * outside its chroot — so signature/initial SVGs are copied to a temp file
 * (inside the chroot) and cleaned up after the PDF is generated.
 */
class PdfExport
{
    /**
     * Render a blade view to a PDF and stream it inline for browser preview.
     */
    public static function make(string $view, array $data, string $filename): Response
    {
        $pdf = Pdf::loadView($view, $data);
        $pdf->setOptions(['chroot' => [base_path(), sys_get_temp_dir()]]);

        $content = $pdf->output();

        foreach (glob(sys_get_temp_dir().'/dcprs-*') ?: [] as $file) {
            @unlink($file);
        }

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => "inline; filename={$filename}.pdf",
        ]);
    }

    /**
     * Copy a stored SVG (public disk) to a temp file so dompdf can render it
     * as an <img>. Returns the temp path, or null when there is nothing.
     */
    public static function svgFile(string|null $path, string $prefix = 'dcprs-svg-'): ?string
    {
        if (! $path) {
            return null;
        }

        if (! Storage::disk('public')->exists($path)) {
            return null;
        }

        $tmp = tempnam(sys_get_temp_dir(), $prefix);
        file_put_contents($tmp, Storage::disk('public')->get($path));

        return $tmp;
    }
}
