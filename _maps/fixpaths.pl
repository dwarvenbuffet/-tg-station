#!/usr/bin/perl -pi
#ha ha time for regexes
#
#This is not the best solution for fixing pathes, but it works faster than opening every dmm and correcting the pathes there
use warnings;
use strict;
s@/obj/item/device/analyzer/plant_analyzer@/obj/item/device/plant_analyzer@g;

