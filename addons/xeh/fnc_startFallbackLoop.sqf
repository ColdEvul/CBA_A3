#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: CBA_fnc_startFallbackLoop

Description:
    Starts a loop to iterate through all objects to initialize event handlers on XEH incompatible objects.
    Internal use only.

Parameters:
    None

Returns:
    None

Examples:
    (begin example)
        call CBA_fnc_startFallbackLoop;
    (end)

Author:
    commy2
---------------------------------------------------------------------------- */

if (GVAR(fallbackRunning)) exitWith {};

GVAR(fallbackRunning) = true;

{
    // don't run init and initPost event handlers on objects that already exist
    SETINITIALIZED(_x);
    true
} count (entities [[], [], true, true]);

GVAR(entities) = [];

[{
    SCRIPT(fallbackLoopPFEH);
    private _entities = entities [[], [], true, true];

    if !(_entities isEqualTo GVAR(entities)) then {
        private _newEntities = _entities - GVAR(entities);
        GVAR(entities) = _entities;

        {
            if !(ISPROCESSED(_x)) then {
                _x call CBA_fnc_initEvents;

                if !(ISINITIALIZED(_x)) then {
                    _x call CBA_fnc_init;
                };
            };
        } forEach _newEntities;
    };
}, 0.1, []] call CBA_fnc_addPerFrameHandler;
