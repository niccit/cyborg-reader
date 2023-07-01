# SPDX-License-Identifier: MIT

# Introducing a one button audible book reader
# This Ebook reader is designed specifically for people who may find working with more complex
# technologies too challenging
# One button does everything - Play, Pause, Resume
# Multiple book directories are supported
# Ebook reader saves state, currently at the change of a chapter and/or a book

import sys
import time
import board
import sdcardio
import storage
import os
import audiobusio
import audiomixer
import digitalio
import neopixel
import displayio
from adafruit_debouncer import Debouncer
from audiocore import WaveFile
from adafruit_st7789 import ST7789
from adafruit_seesaw import seesaw, rotaryio

# We do this to clear the pins associated with the display
# If we don't do this, on reset we'll get an error that says
# "<PIN for tft_dc> is busy"
displayio.release_displays()

# We need these for SD Card, Display, and the volume control
spi = board.SPI()
i2c = board.I2C()

# --- Global Variables --- #

# Set this to true and put any testing specific print statements in the debugging block
DEBUG = True

# The wave file we will play
# Setting to none so that we can handle the error if
# for some reason the wave file doesn't get set properly
wave = None

# Global variables for book handling
books = []  # array of books
chapters = []  # array of chapters based on active book
current_book = 0
current_chapter = 0
total_chapters = 0
total_books = 0

# This is the image for the book we are reading
book_image = None

# --- SD Card set up --- #
cs = board.D13
sdcard = sdcardio.SDCard(spi, cs)
vfs = storage.VfsFat(sdcard)
storage.mount(vfs, "/sd")

# --- Audio Set up --- #
audio = audiobusio.I2SOut(bit_clock=board.D24, word_select=board.D25, data=board.A3)
# We only have one voice, the format of the wave files needs to be 16-bit PCM, wave files, if stereo
# need to be merged to mono - 1 channel, the Project Rate(Hz) for the files needs to be 16000,
# and all wave files must be Microsoft signed
mixer = audiomixer.Mixer(voice_count=1, sample_rate=16000, channel_count=1,
                         bits_per_sample=16, samples_signed=True, buffer_size=32768)
# Default volume level
mixer.voice[0].level = 0.15

# ---- Play/Pause/Resume Key set up --- #
button_play_in = digitalio.DigitalInOut(board.D5)
button_play_in.pull = digitalio.Pull.UP
button_play = Debouncer(button_play_in)

# --- Keyboard and Neopixel set up --- #
# Colors
READY = 0xF00FFF  # Purple
PLAY = 0x00F000  # Green
PAUSE = 0xF0F000  # Yellow
NEED_BOOK = 0xF0000F  # Red Purple

# Keyboard setup
pixel_pin = board.D9
pixels = neopixel.NeoPixel(pixel_pin, 2, brightness=1.0)

# --- Display set up --- #
tft_cs = board.D10
tft_dc = board.D12
tft_reset = board.D11
display_bus = displayio.FourWire(spi, command=tft_dc, chip_select=tft_cs, reset=tft_reset)
# The way I have the display positioned, it's upside down from default, so I have to rotate the screen 180
# Your needs may vary
display = ST7789(display_bus, width=240, height=320, rotation=180)

# display group
primary_display = displayio.Group()
display.show(primary_display)

# --- Rotary Encoder set up - volume control --- #
volume_control = seesaw.Seesaw(i2c, addr=0x36)  # default address is 0x36
encoder = rotaryio.IncrementalEncoder(volume_control)
# Set our encoder to the 0 position, no matter where we last left it
last_encoder_pos = 0


# --- Methods ---#
# Setters #

# Assign the global variable current_book
# If new is True then don't increment because we're starting at the beginning
def set_current_book(book, new):
    global current_book

    if new is False:
        next_book = book + 1
    else:
        print("Do not need to increment book at this time")
        next_book = book

    current_book = next_book

    book = open(book_state_file, "w")
    book.write(str(current_book))
    book.close()


# Assign the global variable chapters for the active book
# Assign the global variable book image for the display
# All chapters should lead with a two-digit value (ex; 01); OpenAudible will do this for you if you
#    break a book down into chapters
# Sort the chapters to ensure we read the book in the proper order
def set_book_chapters(book_num):
    global chapters, book_image, total_chapters

    book = books[book_num]

    for book_filename in os.listdir(book):
        # Add wave files to the array
        if book_filename.lower().endswith('.wav') and not book_filename.startswith('.'):
            chapters.append(book + "/" + book_filename)

        # Set the book image
        if book_filename.lower().endswith('.bmp') and not book_filename.startswith('.'):
            book_image = (book + "/" + book_filename)

    # We subtract one because arrays start with 0
    total_chapters = len(chapters)

    chapters.sort()


# Assign the global variable current_chapter
# If we're starting a new book, don't increment
def set_current_chapter(chapter, new):
    global current_chapter

    if new is False:
        next_chapter = chapter + 1
    else:
        print("not incrementing chapter number")
        next_chapter = chapter

    current_chapter = next_chapter

    chapter = open(chapter_state_file, "w")
    chapter.write(str(current_chapter))
    chapter.close()


# Assign the global variable wave
# The is what will be played
def set_wave_file():
    global wave, current_chapter
    wav_file = chapters[current_chapter]
    wav = open(wav_file, "rb")
    wave = WaveFile(wav)

    if wave is None:
        print("No wave file to play, something went wrong")
        sys.exit()


# This method will set a transitional audio file to be played
def set_transitional_wave(file):
    wav_file = file
    wav = open(wav_file, "rb")
    tmp_wave = WaveFile(wav)

    return tmp_wave


# Take an image file and set the display
# If no book is being read, or the current book is done, display the default image
# Otherwise display the cover of the book
def set_book_cover(image_file):

    if image_file is not None:
        book_image_bitmap = displayio.OnDiskBitmap(open(image_file, "rb"))
        book_tilegrid = displayio.TileGrid(book_image_bitmap, pixel_shader=book_image_bitmap.pixel_shader)
        primary_display.append(book_tilegrid)
    else:
        print("no image file provided, eject buckaroo!")


# Open state files and set appropriate global variable
def set_starting_points(file, book: bool):
    global current_book, current_chapter

    if book is True:
        with open(file, "r") as in_file:
            current_book = int(in_file.read())
    else:
        with open(file, "r") as in_file:
            current_chapter = int(in_file.read())


# Utilities #

# Using this method makes it easy to find print statements that are temporary
def debug_print(string):
    if DEBUG is True:
        print("DEBUG:", string)


# Check the current book or chapter to the total books or chapters
# If we're high or no value is set, default to 0
def correct_out_of_sync_state(item, book: bool):

    debug_print("correct_out_of_sync_state was passed " + str(item))

    if book is True:
        debug_print("total books are " + str(total_books))
        if item > (total_books - 1) or not os.stat(book_state_file)[6] > 0:
            print("books is out of sync, resetting to 0", item, os.stat(book_state_file)[6])
            set_current_book(0, True)
    else:
        debug_print("total chapters are " + str(total_chapters))
        if item > total_chapters or not os.stat(chapter_state_file)[6] > 0:
            print("chapters is out of sync, resetting to 0", item, os.stat(chapter_state_file)[6])
            set_current_chapter(0, True)


# All things related to moving on to a new book
# Set starting chapter to 0
# Clear chapters array
# Rebuild chapters array for new book
def move_to_new_book():
    global chapters

    if current_book <= (total_books - 1):
        set_current_chapter(0, True)
    else:
        set_current_book(0, True)
        set_current_chapter(0, True)

    chapters = []
    set_book_chapters(current_book)


# --- book Handling --- #
# Get all the book directories
# All directories should lead with a two-digit value (ex; 01)
# We will sort the array and start with the first book
for filename in os.listdir("/sd/book"):
    books.append("/sd/book/" + filename)

# We subtract one because arrays start with 0
total_books = len(books)
books.sort()

# --- State Handling --- #
# These are the files where we store our active book and current chapter
# We need this in case the reader loses power
for filename in os.listdir("/sd"):
    # The reader may have to re-listen to the chapter
    # This is due to GitHub issue: https://github.com/adafruit/circuitpython/issues/8055
    # audiocore.WaveFile does not currently support seek()
    if filename.lower().startswith('chapters') and not filename.lower().startswith('.'):
        chapter_state_file = "/sd/" + filename
        # Set global variable current_chapter
        set_starting_points(chapter_state_file, False)

    # Make sure we know what book we're reading
    if filename.lower().startswith('books') and not filename.lower().startswith('.'):
        book_state_file = "/sd/" + filename
        # Set global variable current_book
        set_starting_points(book_state_file, True)


# --- Default Image for Display --- #

# File is stored on the board SPI Flash
# Image by FreePik (https://www.freepik.com/free-vector/hand-drawn-flat-design-stack-books_24372889.htm)
default_image = "images/begin_reading.bmp"

# --- Transition audio --- #

# These files are instructional, one plays at startup, one at the end of a book, and one at the end of all books
welcome_message = "audio_files/Begin_reading.wav"
next_book = "audio_files/Move_to_next_book.wav"
books_finished = "audio_files/Books_finished.wav"
test_file = "audio_files/01-Identity.wav"

# --- Set the player up to begin reading --- #

print("Let's Read!")

# Ensure current book state file is not out of sync
correct_out_of_sync_state(current_book, True)
print("Book to read is:",  books[current_book])

# The get the chapters for the current book
set_book_chapters(current_book)

# Ensure current chapter state file is not out of sync
correct_out_of_sync_state(current_chapter, False)

# Display the default image
set_book_cover(default_image)

# Set the neopixel of the key to be READY
pixels[0] = READY

# Set this to false since we're just starting things up
# This variable is used to determine if we're actively reading a book
PLAY_STATE = False

# Play the welcome/instructional message once at start up
WELCOME = False

while True:
    # Listen for button pushes
    button_play.update()

    # Get the status of the rotary encoder so the mixer voice level can be adjusted
    encoder_pos = -encoder.position
    if encoder_pos != last_encoder_pos:
        encoder_delta = encoder_pos - last_encoder_pos
        volume_adjust = min(max((mixer.voice[0].level + (encoder_delta * 0.005)), 0.0), 1.0)
        mixer.voice[0].level = volume_adjust
        last_encoder_pos = encoder_pos

    if WELCOME is False and not mixer.playing:
        time.sleep(0.1)
        audio.play(mixer)
        time.sleep(0.1)
        audio.pause()
        tmp_wave = set_transitional_wave(welcome_message)
        mixer.voice[0].play(tmp_wave, loop=False)
        audio.resume()
        time.sleep(0.1)
        WELCOME = True

    # Handle the button pushes
    # We're only using one button for simplicity
    # So it has to handle play/pause/resume
    if button_play.fell and mixer.playing:
        if audio.paused:
            print("Resuming playback")
            pixels[0] = PLAY
            audio.resume()
        else:
            print("Button pause pressed")
            pixels[0] = PAUSE
            audio.pause()
    elif button_play.fell and not mixer.playing:
        print("Button play pressed")
        audio.pause()
        # Set wave file here, so we can handle restarting over at the first book
        set_wave_file()
        pixels[0] = PLAY
        set_book_cover(book_image)
        time.sleep(2)
        mixer.voice[0].play(wave, loop=False)
        audio.resume()
        PLAY_STATE = True

    # Handle moving on to the next chapter and/or book
    # We need to use a state along with audio.playing to do this effectively
    # So once we start playing a book we set the PLAY_STATE to true
    if PLAY_STATE is True and not mixer.playing:
        set_current_chapter(current_chapter, False)
        # In the event we are reading more chapters in the same book we preserve that book ID
        tmp_book = current_book
        set_current_book(current_book, False)

        # There are more chapters to read in the current book
        if not current_chapter > (total_chapters - 1):
            print("moving to next chapter")
            audio.pause()
            # reset current book to the proper active book
            set_current_book(tmp_book, True)
            set_wave_file()
            mixer.voice[0].play(wave, loop=False)
            audio.resume()
        # All the chapters are read but there is another book to read
        elif current_chapter > (total_chapters - 1) and not current_book > (total_books - 1):
            print("Yay! You've reached the end of the first book and there's another book to read!")
            audio.pause()
            tmp_wave = set_transitional_wave(next_book)
            mixer.voice[0].play(tmp_wave, loop=False)
            audio.resume()
            time.sleep(10)
            audio.pause()
            move_to_new_book()
            set_wave_file()
            pixels[0] = PLAY
            set_book_cover(book_image)
            time.sleep(2)
            mixer.voice[0].play(wave, loop=False)
            audio.resume()
        # All the chapters in all the books have been read
        # Here we do set up to start over from book 1
        else:
            print("Yay! You've listened to all your books, ask for more!")
            audio.pause()
            tmp_wave = set_transitional_wave(books_finished)
            debug_print("about to play our closing file, telling reader to go get more books!")
            time.sleep(0.1)
            mixer.voice[0].play(tmp_wave, loop=False)
            audio.resume()
            time.sleep(10)
            audio.stop()
            mixer.voice[0].stop()
            pixels[0] = NEED_BOOK
            set_book_cover(default_image)
            move_to_new_book()
            PLAY_STATE = False

    # Sleep briefly in between loops
    time.sleep(0.1)
