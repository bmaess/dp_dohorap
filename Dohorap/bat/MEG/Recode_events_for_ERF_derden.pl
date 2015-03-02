#!/usr/bin/perl

# use this on log files
# Recode_events_for_ERF_derden.pl MEG/motionCorrected/dh52a/dh52a2_mc-enhanced.eve MEG/motionCorrected/dh52a/dh52a2_mc-eh-derden.eve
# 

if ($#ARGV<1) {
   printf "'E: usage: Recode_events_for_ERF_derden.pl MEG/motionCorrected/dh52a/dh52a2_mc-enhanced.eve MEG/motionCorrected/dh52a/dh52a2_mc-eh-derden.eve\n";
   exit 1
}
$infile  = shift @ARGV;
$outfile = shift @ARGV;

$mb{'M'}   = 1;
$mb{'V'}   = 2;

open IN, "<$infile" or die "E: Cannot read from: $infile\n";
open OUT, ">$outfile" or die "E: Cannot write to: $outfile\n";

while (defined($line=<IN>)) {
   chomp $line; $lnno++;
   if ($line=~/^#/) { printf OUT "%s\n",$line; next}
   if ($line=~/(\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s(.+)$/) {
      $boffset   = $1;
      $toffset   = $2;
      $trgbefore = $3;
      $trgafter  = $4;
      $trial     = $5;
      $comment   = $6;
   } else {
      $boffset = 0;
      $toffset = 0.0;
      $trgbefore = 0;
      $trgafter  = 9999;
      $trial     = 999;
      $comment   = 'should not have happened';
   }
   $output_delayed = 0;
   if ($trgafter == 420) {
      $der_condition = 1;
   }
   if ($trgafter == 410) {
      $der_condition = 0;
   }
   if ($trgafter == 520) {
      $right_correct = 1;
   }
   if ($trgafter == 510) {
      $right_correct = 0;
   }
   if ($trgafter =~ /30./) {
      if ($der_condition) { $trgafter += 20; }else{ $trgafter += 10; }
#      $output_delayed = 1;      
#      $cond300_output = sprintf ("%7d %9.3f %6d %6d %3d %s\n",$boffset,$toffset,$trgbefore,$trgafter,$trial,$comment);
   }
#   if ($trgafter =~ /60(.)/) {
#      $incorrect = $1;
#      if ($incorrect) {
#         ($tboffset,$ttoffset,$ttrgbefore,$ttrgafter,$ttrial,@tcomment)=split(/\s/,$cond300_output);
#         printf OUT "%7d %9.3f %6d %6d %3d %s\n",$tboffset,$ttoffset,$ttrgbefore,$ttrgafter+1,$ttrial,@tcomment;
#      } else {     
#         printf OUT "%s",$cond300_output;
#      }
#   }
   if (!$output_delayed) {
      printf OUT "%7d %9.3f %6d %6d %3d %s\n",$boffset,$toffset,$trgbefore,$trgafter,$trial,$comment;
   }
}	
close IN;
close OUT;


