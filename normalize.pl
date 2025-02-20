#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Copy;  # Import the File::Copy module for copying files

### READ FROM FILE PASSED IN THE ARGUMENT
## the script takes one argument, which is the name of the file to be changed
# the script may be run e.g. for file in *.md ; do perl ../../normalize.pl $file ; done
my $DEBUG = 0; # if you set this variable to 0, the source file will be overwritten!

my $file = $ARGV[0];
die ("Specified file $file does not exist") unless (-e $file);
my $tmp = time;

## this script normalizes spacing in Old Rite (pre-Nikonian) texts
my $CombiningCyrillicLetters = join("", map { chr($_) } 0x2DE0..0x2DEF) . chr(0x0487); # add pokrytie
my $NNBS = chr(0x202F);
my $NBSP = chr(0x00A0);
my $punctuation = ".,;:!" . chr(0xA673);
# take care of numerals (numerals are hard)
my $CuDigits = "авгдєѕзиѳіклмнѯопчрстуфхѱѡѿц";
my $titlo = chr(0x0483);

## particles
my $Particles = join("|", ("бо", "бы", "же", "ли", "ми", "мѧ", "ти", "тѧ", "си", "сѧ", "ны", "вы"));
my $Particles2 = join('|', ("безъ", "без̾", "беⷥ", "безо", "въ", "в̾", "во", "да", "до", "за", "і҆", "и҆зъ", "и҆з̾", "и҆зо", "къ", "к̾", "ко", "на", "надъ", "над̾", "наⷣ", "надо", "не", "ни", "ѡ҆", "ѡ҆бъ", "ѡ҆б̾", "ѡ҆бо", "ѿ", "ѡ҆тъ", "ѡ҆то", "по", "подъ", "под̾", "поⷣ", "подо", "предъ", "пред̾", "преⷣ", "предо", "при", "съ", "с̾", "со", "оу҆", "чрезъ", "чрез̾", "чреⷥ", "чрезо", "Безъ", "Без̾", "Беⷥ", "Безо", "Въ", "В̾", "Во", "Да", "До", "За", "І҆", "И҆зъ", "И҆з̾", "И҆зо", "Къ", "К̾", "Ко", "На", "Надъ", "Над̾", "Наⷣ", "Надо", "Не", "Ни", "Ѡ҆", "Ѡ҆бъ", "Ѡ҆б̾", "Ѡ҆бо", "Ѿ", "Ѡ҆тъ", "Ѡ҆то", "По", "Подъ", "Под̾", "Поⷣ", "Подо", "Предъ", "Пред̾", "Преⷣ", "Предо", "При", "Съ", "С̾", "Со", "Оу҆", "Чрезъ", "Чрез̾", "Чреⷥ", "Чрезо"));
my $Particles3 = join('|', ("безъ", "безо", "во", "да", "до", "за", "и҆зо", "ко", "на", "надо", "ѡ҆", "ѡ҆бо", "ѿ", "ѡ҆то", "по", "подо", "предо", "при", "со", "чрезо"));
my $Particles4 = join('|', ("Безъ", "Безо", "Во", "Да", "До", "За", "И҆зо", "Ко", "На", "Надо", "Ѡ҆", "Ѡ҆бо", "Ѿ", "Ѡ҆то", "По", "Подо", "Предо", "При", "Со", "Чрезо"));
my $accents = join('', (chr(0x0300), chr(0x0301), chr(0x0311)));

# assume the CYrillic block only
my $Letters = join("", map { chr($_) } 0x0400..0x04FF) . join("", ("ꙋ", "Ꙋ", "ꙗ", "Ꙗ", chr(0x0300), chr(0x0311), chr(0x0301), chr(0x033E)));

open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file: $!";
open(my $dest_fh, '>:encoding(UTF-8)', "/tmp/$tmp") or die "Could not open destination file: $!";

while (my $text = <$fh>) {

$text =~ s/([$CombiningCyrillicLetters])\s/$1$NNBS/g;
$text =~ s/([$CombiningCyrillicLetters])([$punctuation])/$1$NNBS$2/g;
$text =~ s/([$CuDigits])$titlo([$CuDigits])([$punctuation])/$1$titlo$2$NNBS$3/g;
$text =~ s/([$CuDigits])$titlo([$CuDigits])\s/$1$titlo$2$NNBS/g;
$text =~ s/([$CuDigits])$titlo\s/$1$titlo$NNBS/g;
$text =~ s/([$CuDigits])$titlo([$punctuation])/$1$titlo$NNBS$2/g;
$text =~ s/\s($Particles)(\s)/$NNBS$1$2/g;
$text =~ s/\s($Particles)([$punctuation])/$NNBS$1$2/g;
$text =~ s/([\s\n=])($Particles2)\s/$1$2$NNBS/g;

# 	Rem fix spacing after procyltic particles
$text =~ s/([\s\n=])($Particles3)([$accents])\s/$1$2$3$NNBS/g;
$text =~ s/($Particles4)([$accents])\s/$1$2$NNBS/g;

# 	Rem fix all remaining spacing before punctuation
$text =~ s/([$Letters])([$punctuation])/$1$NBSP$2/g;
# 	Rem fix spacing issues
$text =~ s/ $NBSP/$NBSP/g;
print $dest_fh $text;
}

close ($fh);
close ($dest_fh);

if ($DEBUG) {
    print "Output written to /tmp/$tmp\n";
} else {
    copy ("/tmp/$tmp", $file) or die ("Could not copy temporary file to $file: $!");
    unlink ("/tmp/$tmp") or die ("Could not delete temporary file: $!");
    print "File $file has been modified!\n";
}