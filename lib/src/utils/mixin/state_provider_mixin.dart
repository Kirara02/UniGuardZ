import 'package:flutter/material.dart';

mixin StateProviderMixin<State> {
  @protected
  set state(State value);

  void update(State state) => this.state = state;
}
