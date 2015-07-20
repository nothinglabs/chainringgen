//cam options
makeBoundsForToothCutPocket = "true";
doProjectionFor2dCam = "true";

//general chainring options
numberOfTeeth = 39;
numberOfBolts = 5;
bcd = 110;  //bolt circle diameter
boltHoleDiameter = 10; //seems standard
internalDiameterOffsetFromHoles = 2.75; //seems typical

ringThickness = 2.5;  //seems about right (and is 7075 stock I have..)
toothThickness = 2.1; //should be OK for 8/9 speed - want thinner for 10
toothThinningRadiusInset = 9;

pocketBoundsWidth = 3;

//tooth options
widthPerCog = 12.7; //.5 inch in mm
rollerDiameter = 7.6;
cutDepth = 5.1;
rollerCenterInsetFromExternalDiameter = cutDepth - (rollerDiameter / 2);
roundingDiameter = cutDepth * 5.6;
roundingOffset = cutDepth * 2.48;
toothAspectRatio = .9;

pi = 3.1415;

//openscad resolution
$fa = 8;
$fs = 1;
 
externalDiameter = ((numberOfTeeth * widthPerCog) / pi)  + rollerCenterInsetFromExternalDiameter * 2;
innerDiameter = (bcd - boltHoleDiameter) -  internalDiameterOffsetFromHoles;

translate ([(externalDiameter / 2), (externalDiameter / 2), -1]) {
    if (doProjectionFor2dCam == "true") {
        projection() makeChainRing();    
    } else {
        makeChainRing();
    }
}    


module makeChainRing() {
    
    difference() {    
        cylinder (ringThickness, externalDiameter / 2, externalDiameter / 2);
        for (tooth = [0 : numberOfTeeth]) {
            rotate ([0, 0, (360 / numberOfTeeth) * tooth])
            translate ([externalDiameter / 2, 0, -.1])
            tooth();
        }
        
        for (bolt = [0 : numberOfBolts]) {
            rotate ([0, 0, (360 / numberOfBolts) * bolt])
            translate ([bcd / 2, 0, -.1])
            cylinder (ringThickness * 2, boltHoleDiameter / 2, boltHoleDiameter / 2);
        }

        //inner cut
        translate ([0, 0, -.1])
        cylinder (ringThickness * 2,innerDiameter / 2,innerDiameter / 2);
        
        //thin teeth
        translate ([0, 0, toothThickness])
        teethThin();
        
        if (makeBoundsForToothCutPocket == "true") boundsForToothCutPocket();
        
    }

}

module teethThin() {
    difference() {
        cylinder (ringThickness, (externalDiameter / 2) + 1, (externalDiameter / 2) + 1);
        translate ([0, 0, -.1])
        cylinder (ringThickness + 1, (externalDiameter / 2) - toothThinningRadiusInset,
            (externalDiameter / 2) - toothThinningRadiusInset);
    }
}


module boundsForToothCutPocket() {
    translate ([0, 0, -.1])
    difference() {    
        cylinder (ringThickness + 1, (externalDiameter / 2) - toothThinningRadiusInset,
            (externalDiameter / 2) - toothThinningRadiusInset);
        cylinder (ringThickness + 1, (externalDiameter / 2) - (toothThinningRadiusInset + pocketBoundsWidth),
            (externalDiameter / 2) - (toothThinningRadiusInset + pocketBoundsWidth));    
    }
}    


module tooth(){
    scale ([1,toothAspectRatio,1])
    cylinder (ringThickness * 2, cutDepth, cutDepth);
    translate ([roundingOffset, 0, 0])
    cylinder (ringThickness * 2, roundingDiameter / 2, roundingDiameter / 2);
}