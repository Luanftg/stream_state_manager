import 'package:flutter/cupertino.dart';
import 'package:stream_state_manager/stream_state_manager.dart';

class ComponentWidget<T extends Component, ComponentState>
    extends StatelessWidget {
  final T state;
  final Widget Function(ComponentState) builder;
  final void Function(ComponentState)? onListen;
  final Widget Function(ComponentState)? onClose;
  final Widget Function(ComponentState)? onError;

  const ComponentWidget(
      {super.key,
      required this.state,
      required this.builder,
      this.onClose,
      this.onError,
      this.onListen,
       });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: state.state,
      stream: state.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return onError?.call(snapshot.error as ComponentState) ??
              const SizedBox.shrink();
        }
        if (snapshot.hasData) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
                 WidgetsBinding.instance.addPostFrameCallback((_) =>
                onListen?.call()
              );
              return builder.call(snapshot.data as ComponentState);
            case ConnectionState.done:
              return onClose?.call(snapshot.data as ComponentState) ??
                  const SizedBox.shrink();
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
