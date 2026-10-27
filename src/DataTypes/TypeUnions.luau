export type Supported =
	nil
	| boolean
	| number
	| string
	| buffer
	| { any }
	| { [any]: any }
	| Axes
	| BrickColor
	| CFrame
	| Color3
	| ColorSequence
	| ColorSequenceKeypoint
	| Enum
	| EnumItem
	| Enums
	| Faces
	| FloatCurveKey
	| Font
	| NumberRange
	| NumberSequence
	| NumberSequenceKeypoint
	| Path2DControlPoint
	| PathWaypoint
	| PhysicalProperties
	| Ray
	| Rect
	| Region3
	| Region3int16
	| RotationCurveKey
	| TweenInfo
	| UDim
	| UDim2
	| vector
	| Vector2
	| Vector2int16
	| Vector3
	| Vector3int16
	| DateTime

export type Overridable =
	nil
	| boolean
	| number
	| string
	| buffer
	| Axes
	| BrickColor
	| CFrame
	| Color3
	| ColorSequence
	| ColorSequenceKeypoint
	| Enum
	| EnumItem
	| Enums
	| Faces
	| FloatCurveKey
	| Font
	| NumberRange
	| NumberSequence
	| NumberSequenceKeypoint
	| Path2DControlPoint
	| PathWaypoint
	| PhysicalProperties
	| Ray
	| Rect
	| Region3
	| Region3int16
	| RotationCurveKey
	| TweenInfo
	| UDim
	| UDim2
	| vector
	| Vector2
	| Vector2int16
	| Vector3
	| Vector3int16
	| DateTime

export type Readers = {
	["nil"]: (b: buffer, offset: number) -> (nil, number),
	boolean: (b: buffer, offset: number) -> (boolean, number),
	number: (b: buffer, offset: number) -> (number, number),
	string: (b: buffer, offset: number) -> (string, number),
	buffer: (b: buffer, offset: number) -> (buffer, number),
	table: (b: buffer, offset: number) -> ({ any } | { [any]: any }, number),
	Axes: (b: buffer, offset: number) -> (Axes, number),
	BrickColor: (b: buffer, offset: number) -> (BrickColor, number),
	CFrame: (b: buffer, offset: number) -> (CFrame, number),
	Color3: (b: buffer, offset: number) -> (Color3, number),
	ColorSequence: (b: buffer, offset: number) -> (ColorSequence, number),
	ColorSequenceKeypoint: (b: buffer, offset: number) -> (ColorSequenceKeypoint, number),
	Enum: (b: buffer, offset: number) -> (Enum, number),
	EnumItem: (b: buffer, offset: number) -> (EnumItem, number),
	Enums: (b: buffer, offset: number) -> (Enums, number),
	Faces: (b: buffer, offset: number) -> (Faces, number),
	FloatCurveKey: (b: buffer, offset: number) -> (FloatCurveKey, number),
	Font: (b: buffer, offset: number) -> (Font, number),
	NumberRange: (b: buffer, offset: number) -> (NumberRange, number),
	NumberSequence: (b: buffer, offset: number) -> (NumberSequence, number),
	NumberSequenceKeypoint: (b: buffer, offset: number) -> (NumberSequenceKeypoint, number),
	Path2DControlPoint: (b: buffer, offset: number) -> (Path2DControlPoint, number),
	PathWaypoint: (b: buffer, offset: number) -> (PathWaypoint, number),
	PhysicalProperties: (b: buffer, offset: number) -> (PhysicalProperties, number),
	Ray: (b: buffer, offset: number) -> (Ray, number),
	Rect: (b: buffer, offset: number) -> (Rect, number),
	Region3: (b: buffer, offset: number) -> (Region3, number),
	Region3int16: (b: buffer, offset: number) -> (Region3int16, number),
	RotationCurveKey: (b: buffer, offset: number) -> (RotationCurveKey, number),
	TweenInfo: (b: buffer, offset: number) -> (TweenInfo, number),
	UDim: (b: buffer, offset: number) -> (UDim, number),
	UDim2: (b: buffer, offset: number) -> (UDim2, number),
	vector: (b: buffer, offset: number) -> (vector, number),
	Vector2: (b: buffer, offset: number) -> (Vector2, number),
	Vector2int16: (b: buffer, offset: number) -> (Vector2int16, number),
	Vector3: (b: buffer, offset: number) -> (Vector3, number),
	Vector3int16: (b: buffer, offset: number) -> (Vector3int16, number),
	DateTime: (b: buffer, offset: number) -> (DateTime, number),
}

export type Writers = {
	["nil"]: (b: buffer, offset: number, value: nil) -> (buffer, number),
	boolean: (b: buffer, offset: number, value: boolean) -> (buffer, number),
	number: (b: buffer, offset: number, value: number) -> (buffer, number),
	string: (b: buffer, offset: number, value: string) -> (buffer, number),
	buffer: (b: buffer, offset: number, value: buffer) -> (buffer, number),
	table: (b: buffer, offset: number, value: { any } | { [any]: any }) -> (buffer, number),
	Axes: (b: buffer, offset: number, value: Axes) -> (buffer, number),
	BrickColor: (b: buffer, offset: number, value: BrickColor) -> (buffer, number),
	CFrame: (b: buffer, offset: number, value: CFrame) -> (buffer, number),
	Color3: (b: buffer, offset: number, value: Color3) -> (buffer, number),
	ColorSequence: (b: buffer, offset: number, value: ColorSequence) -> (buffer, number),
	ColorSequenceKeypoint: (b: buffer, offset: number, value: ColorSequenceKeypoint) -> (buffer, number),
	Enum: (b: buffer, offset: number, value: Enum) -> (buffer, number),
	EnumItem: (b: buffer, offset: number, value: EnumItem) -> (buffer, number),
	Enums: (b: buffer, offset: number, value: Enums) -> (buffer, number),
	Faces: (b: buffer, offset: number, value: Faces) -> (buffer, number),
	FloatCurveKey: (b: buffer, offset: number, value: FloatCurveKey) -> (buffer, number),
	Font: (b: buffer, offset: number, value: Font) -> (buffer, number),
	NumberRange: (b: buffer, offset: number, value: NumberRange) -> (buffer, number),
	NumberSequence: (b: buffer, offset: number, value: NumberSequence) -> (buffer, number),
	NumberSequenceKeypoint: (b: buffer, offset: number, value: NumberSequenceKeypoint) -> (buffer, number),
	Path2DControlPoint: (b: buffer, offset: number, value: Path2DControlPoint) -> (buffer, number),
	PathWaypoint: (b: buffer, offset: number, value: PathWaypoint) -> (buffer, number),
	PhysicalProperties: (b: buffer, offset: number, value: PhysicalProperties) -> (buffer, number),
	Ray: (b: buffer, offset: number, value: Ray) -> (buffer, number),
	Rect: (b: buffer, offset: number, value: Rect) -> (buffer, number),
	Region3: (b: buffer, offset: number, value: Region3) -> (buffer, number),
	Region3int16: (b: buffer, offset: number, value: Region3int16) -> (buffer, number),
	RotationCurveKey: (b: buffer, offset: number, value: RotationCurveKey) -> (buffer, number),
	TweenInfo: (b: buffer, offset: number, value: TweenInfo) -> (buffer, number),
	UDim: (b: buffer, offset: number, value: UDim) -> (buffer, number),
	UDim2: (b: buffer, offset: number, value: UDim2) -> (buffer, number),
	vector: (b: buffer, offset: number, value: vector) -> (buffer, number),
	Vector2: (b: buffer, offset: number, value: Vector2) -> (buffer, number),
	Vector2int16: (b: buffer, offset: number, value: Vector2int16) -> (buffer, number),
	Vector3: (b: buffer, offset: number, value: Vector3) -> (buffer, number),
	Vector3int16: (b: buffer, offset: number, value: Vector3int16) -> (buffer, number),
	DateTime: (b: buffer, offset: number, value: DateTime) -> (buffer, number),
}

return {}
