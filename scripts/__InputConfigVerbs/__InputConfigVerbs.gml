
function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        UP,
        DOWN,
        LEFT,
        RIGHT,

        PRIMARY,
        SECONDARY,

        SYSTEM,
        MENU,
    }

    enum INPUT_CLUSTER
    {
        NAVIGATION,
    }

    // Movement
    InputDefineVerb(INPUT_VERB.UP,    "up",    [vk_up,    "W"], [-gp_axislv, gp_padu]);
    InputDefineVerb(INPUT_VERB.DOWN,  "down",  [vk_down,  "S"], [ gp_axislv, gp_padd]);
    InputDefineVerb(INPUT_VERB.LEFT,  "left",  [vk_left,  "A"], [-gp_axislh, gp_padl]);
    InputDefineVerb(INPUT_VERB.RIGHT, "right", [vk_right, "D"], [ gp_axislh, gp_padr]);

    // Main buttons
    InputDefineVerb(INPUT_VERB.PRIMARY,   "primary",   [vk_space, "Z"], gp_face1);
    InputDefineVerb(INPUT_VERB.SECONDARY, "secondary", [vk_shift, "X"], gp_face2);

    // Navigation
    InputDefineVerb(INPUT_VERB.SYSTEM, "system", vk_escape, gp_start);
    InputDefineVerb(INPUT_VERB.MENU,   "menu",   vk_tab,    gp_select);

    // Movement cluster
    InputDefineCluster(
        INPUT_CLUSTER.NAVIGATION,
        INPUT_VERB.UP,
        INPUT_VERB.RIGHT,
        INPUT_VERB.DOWN,
        INPUT_VERB.LEFT
    );
}
