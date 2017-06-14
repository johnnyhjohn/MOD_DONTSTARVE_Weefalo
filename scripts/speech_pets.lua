return {
    SPEECH_PETS = 
    {
        PORTUGUES =
        {   
            JILL =
            {
                ATTACK = {},
                
                STATUS =
                {
                    EMPTY = "Mooo!",
                    HALF  = "Mooo! Muuu!",
                    FULL  = "Mooo! Muuu! Mooo!",    
                }, 
                
                ACTION =
                {
                        
                }, 
                
                EAT =
                {
                    FULL  = "Mooo...",
                    EMPTY = "Moooo!...",  
                },
                
                REFUSE = "Mooo!... Moo!",
                
                DISTANCIA =
                {
                      FAR   ="",
                      CLOSE ="",
                },
            },
            
            
            JAO =
            {
                SUMMON =
                {
                    SKIP  = "APARECA MEU ESCUDO DE PEDRA!!!",
                    RHINO = "VENHA SENHOR DA DESTRUICAO!!!",
                    CHOP  = "EU INVOCO A ARVORE DA PROTECAO, CHOP!!!",
                    JILL  = "EU CONJURO A MONTARIA MAIS RAPIDA, JILL!!!",
                    ARON  = "DAS SOMRAS EU INVOCO ARON!!!",   
                },
                
                FEED =
                {
                    SKIP  = 
                    {
                        ZERO = "Como voce esta, Skip?", 
                        UM   = "Esta com fome parceiro?", 
                        DOIS = "Coma alguma coisa.",
                        FAIL = "Tenho que invoca-lo primeiro!",
                    },   
                    RHINO = {
                        ZERO = "Quem ta com Fominha?", 
                        UM   = "Olha so o pedacao de carne", 
                        DOIS = "Quem quer um bifinho?",
                        FAIL = "Cade o Rhino? Esqueci de invoca-lo",
                    },
                    CHOP  = 
                    {
                        ZERO = "Esta com fome, Chop?", 
                        UM   = "Vai uma adubo ai?", 
                        DOIS = "Acho que voce precisa de um fertilizante...",
                        FAIL = "Oops esqueci do chop",
                    },
                    JILL  = 
                    {
                        ZERO = "Quer um capim?", 
                        UM   = "Eu tenho umas folhinas aqui...", 
                        FAIL = "A Jill nem esta aqui", 
                    },
                    ARON  = 
                    {
                        ZERO = "Quer uma cenoura amiguinho?", 
                        UM   = "Tenho algumas frutas aqui!", 
                        FAIL = "Onde esta aquele coelho bonitinho?",
                    },            
                },
                
                ACTION =
                {
                    JILL  = 
                    {
                        ZERO = {}, 
                        UM   = {}, 
                        FAIL = {},
                    },
                },
                
                SECONDACTION =
                {
                    RHINO = {},
                    CHOP  = {},
                    JILL  = {},
                },
                
                CALL =
                {
                    JILL  = "Jill, vamos galopar para longe daqui!",
                },
                
                WAIT =
                {
                    JILL  = "Jill, ja volto",
                },
            },
        },

        ENGLISH =
        {
            SKIP =
            { 
                ATTACK = "STONE PUNCH!",
                
                STATUS = 
                {
                    EMPTY = "I'm very hungry master, please give me some rocks!",
                    HALF  = "Until some stones would well ...",
                    FULL  = "I'm fine master! \n Ready to work!",
                },
                    
                ACTION = 
                {
                    PICK = "I'll get all that is on the floor!",
                    DROP = "Okay, it's all here!",
                    FAIL = "I don't have anything with me",
                },
                
                EAT =
                {
                    FULL  = "I'm already very full",
                    EMPTY = "Thank you master!",  
                },
                
                REFUSE = "Master, I can't eat that!",
                
                DISTANCIA =
                {
                      FAR   = "Where is my master!",
                      CLOSE = "Master not leave without me!",
                },
            },
            
            RHINO =
            {
                ATTACK = "RHINO SMASH!...",
                
                STATUS =
                {
                    EMPTY = "HUNGRY! HUNGER! FOOD!",
                    HALF  = "Food! Almost full!",
                    FULL  = "Full! Full! \n Destroy things!",
                },
                
                ACTION =
                {
                    SMASH = "DESTROY!!",
                    FAIL  = "Rhino ... not ... ... destroy it!",
                },
                
                EAT =
                {
                    FULL  = "Full!!!",
                    EMPTY = "DESTROY THINGS NOW !!!",  
                },
                
                REFUSE = "That's not meat!",
                
                DISTANCIA =
                {
                      FAR   = "MASTERRR! WE WILL DESTROY THINGS!",
                      CLOSE = "I found ... We will destroy now?",
                },
            },
            
            CHOP = 
            {
                ATTACK = "GONNA... DIE...",
                
                STATUS = 
                {
                    EMPTY = "I... need... food...!",
                    HALF  = "I'm... half... full...",
                    FULL  = "I'm... full",    
                },
                
                ACTION =
                {
                    PROTECT = "All right..., appears my guards!!...",
                    FAIL    = "Chop... doesn't... protect... more!",  
                },
                
                EAT =
                {
                    FULL  = "I'm... full...",
                    EMPTY = "Thanks...",  
                },
                
                REFUSE = "I... don't... like... it...",
                
                DISTANCIA =
                {
                      FAR   = "MA..SSS.TEERR..!!!",
                      CLOSE = "PROTECTTT...!!!",
                },
            },
            
            MINICHOP = 
            {
                ATTACK = {},
                
                KEEPFACE = {},
                
                ACTION =
                {
                    FIGHT  = {"FOR MASTER!", "DEFEND!", "SAVE MASTER!"},
                    GOHOME = {"NEED DEFEND!", "I PROTECT", "MASTER! MASTER!"},
                    TORCH  = {"THE FIRE IS RUNNING OUT", "MAKE FIRE SHINE", "MORE FIRE"},
                    LOOKAT = {"YOU GET OUT", "GO WAY", "YOU NO STAY"},  
                },
            },
            
            JILL =
            {
                ATTACK = {},
                
                STATUS =
                {
                    EMPTY = "Mooo!",
                    HALF  = "Mooo! Muuu!",
                    FULL  = "Mooo! Muuu! Mooo!",    
                }, 
                
                ACTION =
                {
                        
                }, 
                
                EAT =
                {
                    FULL  = "Mooo...",
                    EMPTY = "Moooo!...",  
                },
                
                REFUSE = "Mooo!... Moo!",
                
                DISTANCIA =
                {
                      FAR   ="",
                      CLOSE ="",
                },
            },
            
            ARON =
            {
                ATTACK = {},
                
                STATUS =
                {
                    EMPTY = "MEET... I need meat!",
                    HALF  = "Squeak, squeak!",
                    FULL  = "Squeak, squeak, squeak!",
                },
                
                ACTION = 
                {
                    TRANSFORMA = "I' free...!",
                    DESTRANSFORMA = "Nooo...!",                    
                },
                
                EAT =
                {
                    FULL  = "Squeak!",
                    EMPTY = "Squeak, squeak!...",  
                },
                
                REFUSE = "Squeakkkkk!",
                
                DISTANCIA =
                {
                      FAR   = "MASTER!!!",
                      CLOSE = "I found you!!",
                },
            },
            
            WEREARON = 
            {
                ATTACK = "You're done!!!",
                
                STATUS = 
                {
                    EMPTY = "MEAT... I need meat!",
                    HALF  = "Fooddd!",
                    FULL  = "Full! Let's hunt!",            
                },
                
                ACTION =
                {
                    HUNTER = "HUNTTT!!",
                    FAIL = "I can't attack this...",
                },
                
                EAT =
                {
                    FULL  = "Full! I want to attack!...",
                    EMPTY = "Eat now, then attack!",  
                },
                
                REFUSE = "Squeakkkkk!",
                
                DISTANCIA =
                {
                      FAR   = "",
                      CLOSE = "",
                },
            },
            
            JARVI =
            {
                SKIP  = "The Skip is in trouble",
                RHINO = "Master! Rhino is being attacked...",
                CHOP  = "The base need help, Chop was attacked ...",
                JILL  = "Master help Jill, she not attacks remember? ...",
                ARON  = "Aron is out of control",
                JAO =
                {
                    HEALTH = "Master some rest \n your life is low",
                    SANITY = "His health is low. \n Step away from the others so I can regenerates it",
                    HUNGER = "This hungry Master? \n Whatever sins for Aron get some meat ...",
                },
                ENEMIES =
                { 
                    GIANT = "GIANT FORWARD... Rescue master!",
                    SMALL = "Small group of enemies to face, be careful",
                    HUGE  = "Several monsters forward, better ask for help!",
                },
                  
            },
            
            JAO =
            {
                SUMMON =
                {
                    SKIP  = "APPEARS MY STONE SHIELD!!!",
                    RHINO = "COME LORD OF DESTRUCTION!!!",
                    CHOP  = "I SUMMON THE TREE OF PROTECTION, CHOP!!!",
                    JILL  = "I CONJURE RIDE MORE FAST, JILL!!!",
                    ARON  = "SHADOW I CALL UPON ARON!!!",   
                },
                
                FEED =
                {
                    SKIP  = 
                    {
                        ZERO = "How are you, Skip?", 
                        UM   = "Are you hungry buddy?", 
                        DOIS = "Eat something.",
                        FAIL = "I have to invoke it first!",
                    },   
                    RHINO = 
                    {
                        ZERO = "Who's with greedy?", 
                        UM   = "Look so the piece of meat", 
                        DOIS = "Who wants a piece of meat?",
                        FAIL = "Where is Rhino? I forgot to invoke it",
                    },
                    CHOP  = 
                    {
                        ZERO = "Are you hungry?", 
                        UM   = "Go one fertilizer there?", 
                        DOIS = "I think you need a fertilizer ...",
                        FAIL = "Oops I forgot the Chop",
                    },
                    JILL  = 
                    {
                        ZERO = "Want a grass?", 
                        UM   = "I have a little leaves here ...", 
                        FAIL = "Jill is not here", 
                    },
                    ARON  = 
                    {
                        ZERO = "You want a carrot, buddy?", 
                        UM   = "I have some fruit here! ", 
                        FAIL = "Where's that cute little bunny?",
                    },            
                },
                
                ACTION =
                {
                    SKIP  = 
                    {
                        ZERO = "Skip, take these items", 
                        UM   = "Go get those things", 
                        FAIL = "I'm old nor even invoked!",
                    },
                    RHINO = 
                    {
                        ZERO = "Rhino, destroy it there!", 
                        UM   = "Destroy it!", 
                        FAIL = "Oops nor even invoked!",
                    },
                    CHOP  = 
                    {
                        ZERO = "Chop, protect this area", 
                        UM   = "Defend here!", 
                        FAIL = "I'm old nor even invoked!",
                    },
                    JILL  = 
                    {
                        ZERO = {}, 
                        UM   = {}, 
                        FAIL = {},
                    },
                    ARON  = 
                    {
                        ZERO = "Aron, transform yourself", 
                        UM   = "Let the monster out!", 
                        FAIL = "Oops nor even invoked!",
                    },
                },
                
                SECONDACTION =
                {
                    SKIP  = {
                        ZERO = "Skip, place here the items you picked up", 
                        UM   = "Leave it here", 
                        FAIL = "I'm old nor even invoked!",
                    },
                    RHINO = {},
                    CHOP  = {},
                    JILL  = {},
                    ARON  = 
                    {
                        ZERO = "Aron, face the attack there!", 
                        UM   = "Attack him!", 
                        FAIL = "Oops nor even invoked!",
                    },
                },
                
                CALL =
                {
                    SKIP  = "SKIP!!! DEFEND ME!",
                    RHINO = "Rhino, I need you here!",
                    CHOP  = "Chop! I need strength here",
                    JILL  = "Jill, we galloped away from here!",
                    ARON  = "Aron! I need your lack of sanity here!",
                },
                
                WAIT =
                {
                    SKIP  = "Skip, wait here for a while ...",
                    RHINO = "Don't break anything, Rhino",
                    CHOP  = "Chop! Will do photosynthesis yet!",
                    JILL  = "Jill, be right back",
                    ARON  = "Try not to attack anything, Aron!",
                },
            },
        },

    }
}