defmodule JsTracker.TrackerTest do
  use JsTracker.DataCase

  alias JsTracker.Tracker

  describe "targets" do
    alias JsTracker.Tracker.Target

    @valid_attrs %{url: "some url"}
    @update_attrs %{url: "some updated url"}
    @invalid_attrs %{url: nil}

    def target_fixture(attrs \\ %{}) do
      {:ok, target} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracker.create_target()

      target
    end

    test "list_targets/0 returns all targets" do
      target = target_fixture()
      assert Tracker.list_targets() == [target]
    end

    test "get_target!/1 returns the target with given id" do
      target = target_fixture()
      assert Tracker.get_target!(target.id) == target
    end

    test "create_target/1 with valid data creates a target" do
      assert {:ok, %Target{} = target} = Tracker.create_target(@valid_attrs)
      assert target.url == "some url"
    end

    test "create_target/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_target(@invalid_attrs)
    end

    test "update_target/2 with valid data updates the target" do
      target = target_fixture()
      assert {:ok, target} = Tracker.update_target(target, @update_attrs)
      assert %Target{} = target
      assert target.url == "some updated url"
    end

    test "update_target/2 with invalid data returns error changeset" do
      target = target_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_target(target, @invalid_attrs)
      assert target == Tracker.get_target!(target.id)
    end

    test "delete_target/1 deletes the target" do
      target = target_fixture()
      assert {:ok, %Target{}} = Tracker.delete_target(target)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_target!(target.id) end
    end

    test "change_target/1 returns a target changeset" do
      target = target_fixture()
      assert %Ecto.Changeset{} = Tracker.change_target(target)
    end
  end
end
