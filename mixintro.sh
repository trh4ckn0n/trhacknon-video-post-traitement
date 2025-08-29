#!/bin/bash

# --- Dossiers ---
INTROS_DIR="./intros"
MOVIES_DIR="./movies"
OUTPUT_DIR="./output"
TEMP_DIR="./temp"

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# --- Sélection interactive des fichiers ---
echo "📂 Choisissez l'intro :"
select INPUT_INTRO in "$INTROS_DIR"/*.mp4; do
    [ -n "$INPUT_INTRO" ] && break
    echo "⚠️ Choix invalide."
done

echo "📂 Choisissez le film :"
select INPUT_MOVIE in "$MOVIES_DIR"/*; do
    [ -n "$INPUT_MOVIE" ] && break
    echo "⚠️ Choix invalide."
done

# --- Conversion MKV → MP4 si nécessaire ---
EXT="${INPUT_MOVIE##*.}"
if [ "$EXT" != "mp4" ]; then
    echo "🔄 Conversion de $INPUT_MOVIE en MP4..."
    TMP_MOVIE="$TEMP_DIR/$(basename "$INPUT_MOVIE" ."$EXT").mp4"
    ffmpeg -y -i "$INPUT_MOVIE" -c:v copy -c:a copy "$TMP_MOVIE"
    INPUT_MOVIE="$TMP_MOVIE"
fi

# --- Choix du mode ---
echo "🌐 Choisissez le mode :"
select MODE in "2D" "3D_ACTIF"; do
    [ -n "$MODE" ] && break
    echo "⚠️ Choix invalide."
done

OUTPUT="$OUTPUT_DIR/$(basename "$INPUT_MOVIE" .mp4)-with-intro.mp4"

# --- Paramètres du film ---
MOVIE_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$INPUT_MOVIE")
MOVIE_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$INPUT_MOVIE")
MOVIE_FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$INPUT_MOVIE" | awk -F'/' '{print $1/$2}')
MOVIE_AUDIO_SR=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of csv=p=0 "$INPUT_MOVIE")
MOVIE_AUDIO_CH=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "$INPUT_MOVIE")

# --- Génération de l’intro TRHACKNON ---
TEMP_INTRO="$TEMP_DIR/intro_temp.mp4"
echo "✨ Génération de l'intro $MODE..."

if [ "$MODE" == "3D_ACTIF" ]; then
    ffmpeg -y -f lavfi -i color=c=black:s=${MOVIE_WIDTH}x${MOVIE_HEIGHT}:d=5 \
    -f lavfi -i "sine=frequency=880:duration=0.2,adelay=0|500|1000|1500|2000|2500|3000|3500|4000|4500" \
    -filter_complex "\
    [0:v]split=2[vl][vr]; \
    [vl]drawtext=fontfile=/system/fonts/Roboto-Bold.ttf:text='TRHACKNON TV':fontsize=100:fontcolor=white:x='(w-text_w)/2-10':y='(h-text_h)/2'[vL]; \
    [vr]drawtext=fontfile=/system/fonts/Roboto-Bold.ttf:text='TRHACKNON TV':fontsize=100:fontcolor=white:x='(w-text_w)/2+10':y='(h-text_h)/2'[vR]; \
    [vL][vR]interleave[outv]; \
    [1:a]aresample=$MOVIE_AUDIO_SR[a]" \
    -map "[outv]" -map "[a]" -c:v libx264 -pix_fmt yuv420p -r $MOVIE_FPS -preset veryfast \
    -c:a aac -b:a 192k -ac $MOVIE_AUDIO_CH "$TEMP_INTRO"
else
    ffmpeg -y -f lavfi -i color=c=black:s=${MOVIE_WIDTH}x${MOVIE_HEIGHT}:d=5 \
    -f lavfi -i "sine=frequency=880:duration=0.2,adelay=0|500|1000|1500|2000|2500|3000|3500|4000|4500" \
    -filter_complex "\
    [0:v]drawtext=fontfile=/system/fonts/Roboto-Bold.ttf:text='TRHACKNON TV':fontsize=100:fontcolor=cyan:x=(w-text_w)/2:y=(h-text_h)/2:alpha='if(mod(n,2),1,0.7)'[v]; \
    [1:a]aresample=$MOVIE_AUDIO_SR[a]" \
    -map "[v]" -map "[a]" -c:v libx264 -pix_fmt yuv420p -r $MOVIE_FPS -preset veryfast \
    -c:a aac -b:a 192k -ac $MOVIE_AUDIO_CH "$TEMP_INTRO"
fi

# --- Concat intro + film ---
if [ "$MOVIE_AUDIO_CH" -eq 2 ]; then
    PAN_FILTER="stereo|c0=c0|c1=c1"
elif [ "$MOVIE_AUDIO_CH" -eq 6 ]; then
    PAN_FILTER="5.1|c0=c0|c1=c1|c2=c0|c3=c1|c4=c0|c5=c1"
else
    PAN_FILTER=""
fi

ffmpeg -y -i "$TEMP_INTRO" -i "$INPUT_MOVIE" \
-filter_complex "\
[0:v]setsar=1,fps=$MOVIE_FPS[v0]; \
[0:a]aresample=$MOVIE_AUDIO_SR,pan=$PAN_FILTER[a0]; \
[1:v]setsar=1,fps=$MOVIE_FPS[v1]; \
[1:a]aresample=$MOVIE_AUDIO_SR[a1]; \
[v0][v1]concat=n=2:v=1[outv]; \
[a0][a1]concat=n=2:v=0:a=1[outa]" \
-map "[outv]" -map "[outa]" -c:v libx264 -preset veryfast -crf 23 \
-c:a aac -b:a 192k "$OUTPUT"

# --- Nettoyage ---
rm -f "$TEMP_INTRO"
echo "✅ Film final généré : $OUTPUT"
