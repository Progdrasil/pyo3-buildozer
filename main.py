from my_lib import sum_as_string

import kivy

kivy.require("1.0.9")
from kivy.lang import Builder
from kivy.uix.boxlayout import BoxLayout
from kivy.app import App
from kivy.uix.label import Label

print("RUNNING ON MOBILE")


class MyApp(App):
    def build(self):

        print("[main.py] Building Kivy")

        title = Label(text="Testing pyo3 library using buildozer")

        label = Label(text=sum_as_string(1, 2))
        # self.resetMsg(label)

        layout = BoxLayout(orientation="vertical")
        layout.add_widget(title)
        layout.add_widget(label)
        return layout


if __name__ == "__main__":

    MyApp().run()
