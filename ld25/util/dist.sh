mkdir -p dist
cd src && zip -r9 ../dist/phaedra.love * && cd ..
zip -r9 dist/phaedra.love art
cat `which love` dist/phaedra.love > dist/phaedra && chmod +x dist/phaedra

