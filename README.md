# Gradient input border

Use it with InputDecoration

```dart
InputDecoration(
        ...
        border: GradientOutlineInputBorder(
          focusedGradient: _focusGradient,
          unfocusedGradient: _unfocusGradient,
        ),
      );
```

![demo](demo.gif)


# Gradient Box decoration border

Use it with BoxDecoration

```dart
BoxDecoration(
       border: GradientBorder.uniform(
           width: 3.0,
           gradient: LinearGradient(
               colors: <Color>[Colors.deepOrange, Colors.grey],
               stops: [0.3, 0.5])),
       borderRadius: BorderRadius.circular(Dimens.buttonRadius))
```


<hr/>
Created by iteo
