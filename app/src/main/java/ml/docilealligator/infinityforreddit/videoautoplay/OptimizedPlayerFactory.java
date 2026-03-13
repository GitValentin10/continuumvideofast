package ml.docilealligator.infinityforreddit.videoautoplay;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.DefaultLoadControl;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.LoadControl;

/**
 * Centralized factory for optimized ExoPlayer components.
 *
 * Key optimizations:
 * - bufferForPlaybackMs reduced from 2500ms → 500ms (video starts 5x sooner)
 * - bufferForPlaybackAfterRebufferMs reduced from 5000ms → 1500ms (recovers faster after stall)
 * - minBufferMs kept at 15s (enough to avoid stalls on decent connections)
 * - maxBufferMs increased from 50s → 120s (buffers more ahead, fewer re-fetches)
 * - prioritizeTimeOverSizeThresholds = true (start ASAP even if buffer is small in bytes)
 * - Async MediaCodec queueing forced on (parallel decode/render, fewer dropped frames)
 * - Decoder fallback enabled (graceful degradation on weak hardware)
 */
@UnstableApi
public final class OptimizedPlayerFactory {

    // --- Buffer tuning ---
    // How much data before playback STARTS (default: 2500ms — way too conservative)
    private static final int BUFFER_FOR_PLAYBACK_MS = 500;
    // How much data before playback RESUMES after a rebuffer (default: 5000ms)
    private static final int BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS = 1500;
    // Minimum buffer the player tries to maintain (default: 15000ms — keep it)
    private static final int MIN_BUFFER_MS = 15_000;
    // Maximum buffer the player will accumulate (default: 50000ms → raise to 2 minutes)
    private static final int MAX_BUFFER_MS = 120_000;

    private OptimizedPlayerFactory() {}

    /**
     * Returns an optimized LoadControl for feed autoplay and fullscreen video.
     * Prioritizes fast time-to-first-frame over conservative buffering.
     */
    @NonNull
    public static LoadControl createLoadControl() {
        return new DefaultLoadControl.Builder()
                .setBufferDurationsMs(
                        MIN_BUFFER_MS,
                        MAX_BUFFER_MS,
                        BUFFER_FOR_PLAYBACK_MS,
                        BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS
                )
                .setPrioritizeTimeOverSizeThresholds(true)
                .setBackBuffer(30_000, true) // keep 30s of played-back data, allow re-buffering from it
                .build();
    }

    /**
     * Returns a RenderersFactory with:
     * - Async MediaCodec buffer queueing forced ON (runs decode on a dedicated thread)
     * - Decoder fallback enabled (falls back to software decoder if HW fails)
     */
    @NonNull
    public static DefaultRenderersFactory createRenderersFactory(@NonNull Context context) {
        return new DefaultRenderersFactory(context)
                .setEnableDecoderFallback(true)
                .forceEnableMediaCodecAsynchronousQueueing();
    }

    /**
     * Same as createRenderersFactory but with a specific extension renderer mode.
     */
    @NonNull
    public static DefaultRenderersFactory createRenderersFactory(
            @NonNull Context context,
            @DefaultRenderersFactory.ExtensionRendererMode int extensionMode) {
        return new DefaultRenderersFactory(context)
                .setExtensionRendererMode(extensionMode)
                .setEnableDecoderFallback(true)
                .forceEnableMediaCodecAsynchronousQueueing();
    }
}
