module DateTimePicker.Geometry
    exposing
        ( Point
        , calculateAngle
        , calculateArrowPoint
        )


type alias Point =
    { x : Int, y : Int }


type Quadrant
    = Quadrant1
    | Quadrant2
    | Quadrant3
    | Quadrant4


calculateAngle : Point -> Point -> Point -> Float
calculateAngle p1 p2 p3 =
    let
        quadrant =
            if p3.x >= p1.x && p3.y >= p1.y then
                Quadrant1
            else if p3.x < p1.x && p3.y >= p1.y then
                Quadrant2
            else if p3.x < p1.x && p3.y < p1.y then
                Quadrant3
            else
                Quadrant4

        p12 =
            ((p1.x - p2.x) ^ 2)
                + ((p1.y - p2.y) ^ 2)
                |> toFloat
                |> sqrt

        p13 =
            ((p1.x - p3.x) ^ 2)
                + ((p1.y - p3.y) ^ 2)
                |> toFloat
                |> sqrt

        p23 =
            ((p2.x - p3.x) ^ 2)
                + ((p2.y - p3.y) ^ 2)
                |> toFloat
                |> sqrt

        angle =
            (p12 ^ 2 + p13 ^ 2 - p23 ^ 2)
                / (2 * p12 * p13)
                |> acos
    in
        case quadrant of
            Quadrant3 ->
                angle

            Quadrant4 ->
                angle

            Quadrant1 ->
                (2 * pi) - angle

            Quadrant2 ->
                (2 * pi) - angle


calculateArrowPoint : Point -> Int -> Float -> Point
calculateArrowPoint origin length radians =
    let
        x =
            round (toFloat length * cos radians)

        y =
            round (toFloat length * sin radians)
    in
        { x = origin.x + x, y = origin.y - y }
