#!/usr/local/bin/perl
# IEEE-754 floating point format converter.
# Ver 1.00 Sep.16 1999 Y.Kumano
# Ver 2.04 Sep.30 1999 Y.Kumano
# Ver 2.10 May.21 2000 Y.Kumano
# Ver 2.11 May.21 2000 Y.Kumano

&init;

while(1) {
    print "IEEE-754 format or Real number or 'q' : ";

    $inp = <STDIN>;
    chop($inp);

    redo if($inp eq "");

    exit if($inp eq "q");
    exit if($inp eq "Q");

    $inlen = length($inp);

    $flt_flag = index($inp, ".");

    if(substr($inp, $inlen-1, 1) eq "?") {
        $eval_flag = 1;
    } else {
        $eval_flag = 0;
    }

    if($eval_flag == 1) {
        chop($inp);
        $val = eval($inp);
        printf("Dec_%d  Hex_%x  Oct_%o\n", $val, $val, $val);
    }

    if(($flt_flag != -1) || ($eval_flag == 1)) {
        $val = eval($inp);
        print "$val =>\n";
        if($val != 0.0) {
            &flt2hex($val);
        } else {
            print "can't calculate.\n\n";
        }
        redo;
    }

    $len = 0;
    $newinp = "";
    for($i=0; $i<$inlen; $i++) {
        $digit = substr($inp, $i, 1);
        $tmp = "";
        $tmp = $bin{$digit};
        if($tmp ne "") {
            $len++;
            $newinp .= $digit;
        }
    }

    if($len == 16) {
        &hex2flt($newinp, 64, 11, 52);
        redo;
    }

    if ($len == 8) {
        &hex2flt($newinp, 32, 8, 23);
        redo;
    }

    print "Error: format is wrong.\n\n";
}

sub hex2flt {
    local($i, $bin_seq, $sign_bit, $exp, $frac, $bc);

    local($hex, $bit_len, $exp_len, $frac_len);
    ($hex, $bit_len, $exp_len, $frac_len) = @_;

    $bin_seq = "";

    for($i=0; $i<length($hex); $i++) {
        $hnum = substr($hex,$i,1);
        $bin_seq .= $bin{$hnum};
    }

    $sign_bit = substr($bin_seq, 0, 1);
    if($sign_bit eq "0") {
        $sign = 1;
    } else {
        $sign = -1;
    }

    $exp = 0;
    $bc = 1;
    for($i=0; $i<$exp_len; $i++) {
        $bit = substr($bin_seq, $exp_len-$i, 1);
        if($bit eq "1") {
            $exp += $bc;
        }
        $bc *= 2;
    }
    $exp -= (2**($exp_len-1) - 1);

#    printf("exp = %d\n", $exp);

    $frac = 0;
    $bc = 0.5;
    for($i=0; $i<$frac_len; $i++) {
        $bit = substr($bin_seq, $exp_len+1+$i, 1);
        if($bit eq "1") {
            $frac += $bc;
        }
        $bc /= 2;
    }
    $frac = $frac+1.0;
#    printf("frac = %le\n", $frac);

    $result = $sign * $frac * (2 ** $exp);

#    printf("%s\n", $bin_seq);
    print"$result\n";
    printf("%lf\n", $result);
    printf("%le\n", $result);
    printf("\n");
}

sub flt2hex {
    local($fltnum);
    ($fltnum) = @_;
    
    printf("single:%s\n", &fltTrans($fltnum, 8, 23));
    printf("double:%s\n", &fltTrans($fltnum, 11, 52));

    print "\n";
}

sub fltTrans {
    local($num, $exp_b, $frac_b);
    ($num, $exp_b, $frac_b) = @_;
    local($sign_bit, $exp_bit, $frac_bit);
    local($fullbit);
    local($exp, $frac, $i);
    
    if($num >= 0.0) {
        $sign_bit = "0";
    } else {
        $sign_bit = "1";
        $num = -$num;
    }
    
    $exp = (log($num) / log(2));
    if($exp > 0) {
        $exp = int($exp);
    } else {
        $exp = int($exp) - 1;
    }
    $frac = $num / (2**$exp);

#    print "frac : $frac, exp : $exp\n";

    $frac = $frac - 1;
    $frac_bit = "";
    for($i=1; $i<=$frac_b; $i++) {
        if($frac / 2**(-$i) >= 1.0) {
            $frac_bit .= "1";
            $frac -= 2**(-$i);
        } else {
            $frac_bit .= "0";
        }
    }

    $exp = $exp + (2**($exp_b-1) - 1);
    $exp_bit = "";
    for($i=$exp_b-1; $i>=0; $i--) {
        if($exp & 2**$i) {
            $exp_bit = $exp_bit."1";
        } else {
            $exp_bit = $exp_bit."0";
        }
    }
    $fullbit = $sign_bit.$exp_bit.$frac_bit;

    $bitlen = $exp_b+$frac_b+1;
    $result = "";
    for($i=0; $i<($bitlen/4); $i++) {
        $result = $result.$hex{substr($fullbit, $i*4, 4)};
        if(($i & 3) == 3) {
            $result .= " ";
        }
    }

    # 64bit長の場合の８進数表記
    if($bitlen == 64) {
        $result = $result.": ";

        $fullbit_o1 = "0".substr($fullbit, 0, 32);
        $result .= &bin2oct($fullbit_o1);

        $result .= " _ ";

        $fullbit_o2 = "0".substr($fullbit, 32, 32);
        $result .= &bin2oct($fullbit_o2);
    }
    # 32bit長の場合の８進数表記
    if($bitlen == 32) {
        $result = $result."          : ";

        $fullbit_o = "0".$fullbit;
        $result .= &bin2oct($fullbit_o);
    }

    $result;
}

sub bin2oct {
    local ($inbit);
    local ($bitlen, $i);
    local ($result);

    ($inbit) = @_;
    $result = "";
    $bitlen = length($inbit);
    for($i=0; $i<($bitlen/3); $i++) {
        $result = $result.$oct{substr($inbit, $i*3, 3)};
        if(($i & 3) == 3) {
            $result .= " ";
        }
    }
    $result;
}

sub init {
    $bin{"0"} = "0000";
    $bin{"1"} = "0001";
    $bin{"2"} = "0010";
    $bin{"3"} = "0011";
    $bin{"4"} = "0100";
    $bin{"5"} = "0101";
    $bin{"6"} = "0110";
    $bin{"7"} = "0111";
    $bin{"8"} = "1000";
    $bin{"9"} = "1001";
    $bin{"a"} = "1010"; $bin{"A"} = "1010";
    $bin{"b"} = "1011"; $bin{"B"} = "1011";
    $bin{"c"} = "1100"; $bin{"C"} = "1100";
    $bin{"d"} = "1101"; $bin{"D"} = "1101";
    $bin{"e"} = "1110"; $bin{"E"} = "1110";
    $bin{"f"} = "1111"; $bin{"F"} = "1111";

    $hex{"0000"} = "0";
    $hex{"0001"} = "1";
    $hex{"0010"} = "2";
    $hex{"0011"} = "3";
    $hex{"0100"} = "4";
    $hex{"0101"} = "5";
    $hex{"0110"} = "6";
    $hex{"0111"} = "7";
    $hex{"1000"} = "8";
    $hex{"1001"} = "9";
    $hex{"1010"} = "a";
    $hex{"1011"} = "b";
    $hex{"1100"} = "c";
    $hex{"1101"} = "d";
    $hex{"1110"} = "e";
    $hex{"1111"} = "f";

    $oct{"000"} = "0";
    $oct{"001"} = "1";
    $oct{"010"} = "2";
    $oct{"011"} = "3";
    $oct{"100"} = "4";
    $oct{"101"} = "5";
    $oct{"110"} = "6";
    $oct{"111"} = "7";
}
